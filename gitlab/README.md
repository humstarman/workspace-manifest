# Deploying Gitlab on Kubernetes

Manifests to deploy GitLab on Kubernetes  

## 0 Prerequisites:

1. All configurations are assuming deployment to namespace `gitlab`
2. Domain names used in this project are node ip and port.
3. Some pods are configured with local-volume persistent storage. To update.  

## 1 Deploying Gitlab

First, create a separate namespace for Gitlab
```bash
kubectl create -f gitlab-core/namespace.yaml
kubectl create -f gitlab-core/local-volumes.yaml
```

Deploy PostgreSQL and Redis
```bash
kubectl create -f gitlab-core/postgres.yaml
kubectl create -f gitlab-core/redis.yaml
```

Before deploying Gitlab, some extra works are requiered.  
On Kubernetes, Gitlab can serve in forms of 
- {Container_IP}:{Container_Port} 
- {SVC_IP}:{SVC_Port} 
- {NODE_IP}:{NODE_Port}  
 
As one can deploy ingress controller ahead of Gitlab,  
Gitlab also can use ingress rules to serve.  
By defalut, the `external_url` field of Gitlab is set as a site url.  
Therefore, DNS is critical. Normally, we write the `/etc/hosts`.  
But, in practice, if intergrating with CI implemented by Gitlab-runner,  
a Gitlab-runner may run a docker container to work.  
In this above circumstance, the runned docker container cannot resolve the `external_url` of Gitlab.  
The solution we used is to set the `external_url` in the form of  `http://{Node_IP}:{Node_Port}`.  

On Kubernetes. Gitlab-core service is schedlued by `kube-schedluer`; so in a cluster,  
it is hard to tell the node where the pod of Gitlab resides.  
To achieve this, we label the node, and introduce `NodeSelector` filed to `gitlab-core/gitlab.yaml`.  

Label the node to carry Gitlab  
```bash
kubectl label node {Node_Name} gitlab=true
```

Also, you can label other nodes as (nonessential)
```bash
kubectl label node {Other_Node_Name} gitlab=false
```

Accordingly, modify  `gitlab-core/gitlab.yaml` in two segment  
1. set the value `GITLAB_OMNIBUS_CONFIG` in `.spec.template.spec.containers[0].env` as `http://{Node_IP}:{Node_Port}`
2. in `.spec.template.spec` add `nodeSelector` filed with value `gitlab: "true"`  

Then, deploy Gitlab
```bash
kubectl create -f gitlab-core/gitlab.yaml
```

## 2 Deploying Gitlab-runner

To implement CIi, a exector is needed.  
In this project, we use Gitlab-runner.  
GitLab Runner supports several executors: 
- virtualbox
- docker+machine
- docker-ssh+machine
- docker
- docker-ssh
- parallels
- shell
- ssh  

Here, we use docker as the executor. 
To deploy a runner, two steps are needed.
1. Register the runner in Gitlab
2. Configure the configmap file in `gitlab-runner`, and deploy the runner.  

For registration, we need to obtain GitLab’s own token.  
To get it, login into GitLab as `root`, and navigate to `admin area`.  
Then go to `Overview -> Runners` and copy your registration token.
  
Now we need to configure and register runner.  
We are going to use `kubectl run` command for this.  
It will create deployment, run default command with argument `register in interactive mode.
```bash
$kubectl run -it runner-registrator --image=gitlab/gitlab-runner:latest --restart=Never -- register

Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://{Node_IP}:{Node_Port}
Please enter the gitlab-ci token for this runner:
{Token_from_Gitlab}
Please enter the gitlab-ci description for this runner:
[runner-registrator]: 
Please enter the gitlab-ci tags for this runner (comma separated):

Whether to run untagged builds [true/false]:
[false]: 
Whether to lock the Runner to current project [true/false]:
[true]: 
Registering runner... succeeded                     runner=
Please enter the executor: parallels, ssh, docker+machine, kubernetes, docker, docker-ssh, shell, virtualbox, docker-ssh+machine:
docker
Please enter the default Docker image (e.g. ruby:2.1):
busybox
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

After answering all questions, you should find your runner in the list of runners in the `admin area`.  
Click on it and copy generated token and paste it into the `gitlab-runner/docker-configmap.yml`.  
Make sure the status of the runner are  
- [x] Active: Runners don't accept new jobs
- [x] Run untagged jobs: Indicates whether this runner can pick jobs without tags  
- [ ] Lock to current projects: When a runner is locked, it cannot be assigned to other projects 

The last step is to actually deploy GitLab Runner itself.
```bash
kubectl create -f gitlab-runner/docker-configmap.yaml
kubectl create -f gitlab-runner/docker-controller.yaml
```
