# Hello Microservice

This repository contains the hello microservice from Udacity's server-side Swift curriculum. The hello microservice is a simple Swift server that exposes two endpoints:

- /
  - returns a basic message
- /secure
  - when provided a valid auth token, returns a "secure" message

To experiment with the endpoints, see the [Lesson 1: Hello Microservice Docs on Apiary](http://docs.l1hello.apiary.io/#).

Also, the hello microservice uses the Swift Package Manager to manage dependencies.

## Swift Dependencies

- Kitura
- HeliumLogger
- Perfect-Crypto

## How to Use

The hello microservice can technically be built to run on macOS or Ubuntu Linux. However, we recommend building for Ubuntu Linux since that will likely be the environment used if you were to deploy the microservice into the cloud. Furthermore, to assure consistency between development and possible deployment environments, Docker is used. Take the following steps to build and run the monolith:

**1] Build the Docker Image**

```bash
docker build -t s3-hello:1.0.0 .
```

**2] Run the Docker Image (start Bash shell)**

```bash
docker run --rm -it -v $(pwd):/app -p 8081:8081 s3-hello:1.0.0 /bin/bash
```

**3] Build the Microservice**

```bash
# assuming you are located at /app
swift build
```

**4] Run the Microservice**

```bash
# assuming you are located at /app
.build/debug/hello
```

**5] Test an Endpoint!**

```bash
curl localhost:8081
```
