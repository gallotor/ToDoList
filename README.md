# ToDoList
This is a Todolist web application that uses ejs templating for front-end and uses Node.js and Express for backend. The todo items are stored on a MongoDB database. Initially when you open the application you see three by default added items and you can add more items by adding yourselves and when you add an item a post route is triggered which creates a database item and stores it inside the relevant database. Each route URL has its own database created which stores separate data. You can just access a new route and then create a todolist for that specific route and I used Lodash npm package to format all routes.

Body-parser npm package is used to access the form body values from the ejs template to create a new item. Then I used data.js which has two methods inside which are used to generate the current formatted date and day.

The database is currently connected to localhost:27017 but it can be connected anywhere as wished. The css used to style is stored inside the public directory to serve up static assets.

HOW TO RUN: You can either download the files, and then run "npm install" inside the installation directory to install all the npm packages used within the application and then open a new terminal window and run the MongoShell command "mongod" and then inside the first window run the command "node app.js" to run the app. You can also access the application at : https://vast-reef-18780.herokuapp.com/

Here's a preview:
![Capture](https://user-images.githubusercontent.com/46281169/61468062-1e4c0d80-a996-11e9-8dec-a1cffbd4b59e.PNG)


## Mongodb installation


** Please be patient while the chart is being deployed **

MongoDB(R) can be accessed on the following DNS name(s) and ports from within your cluster:

    mongodb.default.svc.cluster.local

To get the root password run:

    export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

To connect to your database, create a MongoDB(R) client container:

    kubectl run --namespace default mongodb-client --rm --tty -i --restart='Never' --env="MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD" --image docker.io/bitnami/mongodb:4.4.6-debian-10-r8 --command -- bash

    kubectl run --namespace default mongodb-client --rm --tty -i --restart='Never' --env="MONGODB_ROOT_PASSWORD=9EFuHt4GcR" --image docker.io/bitnami/mongodb:4.4.6-debian-10-r8 --command -- bash
    

Then, run the following command:
    mongo admin --host "mongodb" --authenticationDatabase admin -u root -p $MONGODB_ROOT_PASSWORD
      mongo admin --host "mongodb" --authenticationDatabase admin -u root -p 9EFuHt4GcR

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace default svc/mongodb 27017:27017 &
    mongo --host 127.0.0.1 --authenticationDatabase admin -p $MONGODB_ROOT_PASSWORD

## Requirements
Minukube
helm
Install bitnami mongodb chart

## Install

kubectl apply -f .\k8s\deploy.yaml

or

skaffold dev -p local
Update mongodb password 

minikube service todolist

