# ToDoList application deployment automation

## About

[Todolist](https://github.com/msalman81/ToDoList) is a Node.js (Express) application. The TODO items are stored in a remote MongoDB database. It was seleccted for the Automation project due to its simplicity and external DDBB integration.

Here's a preview:
![Capture](https://user-images.githubusercontent.com/46281169/61468062-1e4c0d80-a996-11e9-8dec-a1cffbd4b59e.PNG)

The original project has been forked into my github account:
> https://github.com/gallotor/ToDoList/tree/feature-automation

It includes minimal code modifications fron the original version (for mongodb connection parametrization) and all the required Docker and Kubernetes configuration.

## 📋 Requirements

_What software do we need to install and run the application?_

-  **Nodejs** 10 or above for locally executing the application
-  Local **Docker** installation for container creation
-  A Kubernetes cluster. We'll use **Minikube** as an example implementation.
-  **Helm** for external Mongodb dependencies
-  **Kubectl** cli for kubernetes deployment
-  **Skaffold** can be used for hot reload of the application
-  **Helmfile** if we want to have a single declarative installation script

## 🔨 Installation

## Dependency installation

Since the application depends on MongoDB for external storage, it's necesary to install a local Mongodb DDBB prior to the application execution.

> This document asumes that a local Minikube installation is available and configure with the **metrics-server addon**:

```console
$ minikube addons enable metrics-server
```
## 📏 Deploy Bitnami official MongoDB Chart

First, add [Bitnami chart repository](https://bitnami.com/stacks) to your local helm installation:

```console
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once bitnami is included as a repository, deploy the [MongoDB chart](https://bitnami.com/stack/mongodb/helm) with the following parameters:

```console
$ helm install mongodb --set auth.username=todolist,auth.password=todolist,auth.database=listItemDB bitnami/mongodb
```

> Bitnami MongoDB implements user authentication by default, so It's advisable to include a dedicated username/password for the application database.

To expose the MondoDB service externally, use the following command:
```console
$ kubectl port-forward --namespace default svc/mongodb 27017:27017` 
```

## ✏️ Executing the application locally

To start the application locally, just type the following commands:

```console
$ npm install
$ node app.js
```
The applications will start in the following url:

`http://localhost:8080`

 (remember to set up the port forward of MongoDB port)

## 📦 Executing the application in a local Container

A customized Dockerfile has been included along with the original application. The Dockerfile will execute a multi-stage docker build, using two diferent [Bitnami NodeJS](https://github.com/bitnami/bitnami-docker-node#how-to-use-this-image) images:

```docker
# First build stage
FROM bitnami/node:14 as builder
```

For the initial building and dependency stage and:
```docker
# Second build stage
FROM bitnami/node:14-prod
```

To assemble the dependencies on top of a production ready base image. **The dockerfile enforces good practices** related to container definition, such as using a dedicated, **non privileged user** inside the container. The container executes the application main script and launches it in the port 8080.

Execute this script to build an application image with the *"latest"* tag.

```console
$ docker build --pull --rm -f "Dockerfile" -t todolist:latest "."
```

```console
$ docker run --rm -it -p 8080:8080/tcp todolist:latest
```

## 🚀 Deploying the application in a Kubernetes cluster

Once we verified that the application works in a container deployment, we can generate a Kubernetes descriptor. This file can be found in the k8s/deploy.yaml path of the repository, and it includes the following sections:


### Service

It defines a **LoadBalancer** Kubernetes Cluster, that will enable **service external access**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: todolist
spec:
  ports:
  - port: 8080
  type: LoadBalancer
  selector:
    app: todolist
```

### Deployment
The deployment will define:
* The image:tag to be deployed in the pods 
>in this example we assumed that the todolist:latest image is already present in the local docker daemon and there's no need to pull it from a remote repository: `imagePullPolicy: Never` 
* The resource request and limits to be applied in the pods
* A reference to the environment variable used as configuration for the MongoDB connection string.
  

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todolist
spec:
  selector:
    matchLabels:
      app: todolist
  template:
    metadata:
      labels:
        app: todolist
    spec:
      containers:
      - name: todolist
        image: todolist:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
        envFrom:
          - configMapRef:
              name: todolist
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 256Mi
```

### HPA policies

To ensure a **scalable deployment of the application**, a *HorizontalPodAutoscaler* must be defined. We stablished a minimum and maximum number of replicas, as well as a CPU utilization percentage to determine the replica scale up and down. 

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: todolist
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: todolist
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 50
```

### ConfigMap

Finally, a *ConfigMap* resource defines the connection string to the application MongoDB instance. 


```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: todolist
data:
  MONGODB_CONNECTION: mongodb://todolist:todolist@mongodb:27017/listItemDB
```
It defines an **MONGODB_CONNECTION** environment variable within the pods that is used in the application code to connect to Mongodb:

```javascript
const MONGODB_CONNECTION = process.env.MONGODB_CONNECTION || "mongodb://todolist:todolist@localhost:27017/listItemDB"; 
app.use(express.static("public"));
console.log("Connecting to: "+ MONGODB_CONNECTION );

mongoose.connect(MONGODB_CONNECTION, { useNewUrlParser: true , useUnifiedTopology: true});
```


To **deploy the application in the cluster**, simply type:

```console
$ cd k8s
$ kubectl apply -f deploy.yaml
```

The following minikube command will expose the application:
```console
$ minikube service todolist
```


## 👉 Launch a hot reload deployment for the application

As a bonus, it is simple to stablish an inner loop development cycle with hot reload in the cluster, using [Skaffold](https://skaffold.dev/) from GCP. Skaffold can deploy and reload the application automatically with every source change and it enables a fast and efficient development cycle. To activate the skaffold development mode, simply type:

```console
$ skaffold dev -p local
```

## 💡 Possible improvements

Even though the project doesn't specify it, the application deployment should be more robust and stable through a **Helm Chart**; this will give us release management over the deployment and its values.

To install the application using a chart template, simply type this helm command:

```console
$ helm install todolist .\helm\todolist
```


Moreover, once we define an application Helm chart, it's relatively easy to define a [Helmfile](https://github.com/roboll/helmfile) script that will encapsulate both the application (todolist) and the dependencies (MongoDB) into a single script. 

```yaml
helmDefaults:
  atomic: true
  createNamespace: false
  cleanupOnFail: true
  verify: true
  timeout: 300
  wait: true

bases:
  - "bases/repos.yaml"
  - "bases/environments.yaml"
  - "bases/defaults.yaml"

helmfiles:
  - "releases/database.yaml"
  - "releases/applications.yaml"
```

This command will deploy the complete application and its requirements automaticaly:

```console
$ cd helm
$ helmfile apply
```

See the helm folder of the repository for examples and more detail about helmfile. 


