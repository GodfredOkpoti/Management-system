
# (Food Waste Management System)

Food waste is a major problem in the world, with at least one-third of global food supplies being wasted or lost around the globe every year.

--------------------------------------------------------------------------------------------------------------

## NGINX server Configuration
----
- Configure the NGINX server in all servers.
- Following this command to install and configure NGINX.

- Update the system using this command
```
  sudo yum update -y
```

- Install NGINX using this command
```
sudo yum install nginx
```

- Start NGINX using this command
```
sudo systemctl start nginx
```

- Navigate to this directory for configuration
```
cd /etc/nginx/conf.d/
```
- create a new file called `example.conf`
```
sudo vi example.conf
```
- To set up a proxy and port mapping, you will need to copy the following code.
- Replace 'your server name' with the name or IP address of your server and also port. 
```
server {
    listen       80;
    server_name  13.127.94.52;<you_Server_name>

     location / {
        proxy_pass http://localhost:3000; #whatever port your app runs on
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```
- Check NGINX config

```sudo nginx -t```

- Restart NGINX
  
```sudo nginx -s reload```

# Phase 2: Set up Target group and Load Balancer

## Set up Target Group

In `Amazon Web Services (AWS), a target group` is a logical collection of EC2 instances that a load balancer distributes workload to. A target group can contain instances with any kind of characteristics, and you can create different target groups for different types of requests.

- Create Target Group
- Target type is `Instance`
- give Target Group name and live as default
- `Next` Select EC2 instances for a target group and Click on `Include as pending below`
- Wait for `Health status pass` and click on Create


## Set up a Load balancer

`Application Load Balancer` operates at the request level (layer 7), routing traffic to targets (EC2 instances, containers, IP addresses, and Lambda functions) based on the content of the request. Ideal for advanced load balancing of HTTP and HTTPS traffic, Application Load Balancer provides advanced request routing targeted at delivery of modern application architectures, including microservices and container-based applications. Application Load Balancer simplifies and improves the security of your application, by ensuring that the latest SSL/TLS cyphers and protocols are used at all times.

- Create Load Balancer
- Select `Application Load Balancer` and put all the details.
- Now for the temporary `Listeners and routing` section put Protocol `HTTP`, Prot `80`, and Target Group. 

# Phase 3: Set up a CI/CD Pipeline using AWS Developer tools

### AWS Systems Manager Parameter Store
`Parameter Store`, a capability of AWS Systems Manager, provides secure, hierarchical storage for configuration data management and secrets management. 

### CodeBuild
`AWS CodeBuild` is a fully managed build service in the cloud. CodeBuild compiles your source code, runs unit tests, and produces artefacts that are ready to deploy. 

### CodeDeploy
`AWS CodeDeploy` is a service that automates code deployments to any instance, including Amazon EC2 instances and instances running on-premises. AWS CodeDeploy makes it easier for you to rapidly release new features, helps you avoid downtime during deployment, and handles the complexity of updating your applications.

### CodePipeline
`AWS CodePipeline `is a continuous delivery service you can use to model, visualize, and automate the steps required to release your software. You can quickly model and configure the different stages of a software release process. CodePipeline automates the steps required to release your software changes continuously.

### Git-Secret

`Git-secret` is a tool to manage API secrets in source control -- but it doesn't have to be just API keys. This git extension allows you to encrypt/decrypt any files as you push/pull from source control.

### Snyk 

`Snyk` is a cloud-based security tool that helps developers find and fix vulnerabilities in their applications, containers, infrastructure as code, and open-source dependencies.

- In this project, we scan an Application source code from GitHub and Container Images using **Snyk**.
  
[**Reference Docs from Snyk**](https://docs.snyk.io/integrate-with-snyk/snyk-ci-cd-integrations/aws-codepipeline-integration-by-adding-a-snyk-scan-stage)

[**Reference Docs from Snyk to integrate with CodePipeline**](https://snyk.io/blog/automate-vulnerability-scanning-in-aws-codepipeline-with-snyk/)


# Phase 4: Set up Route53 Hosted Zone

`Amazon Route 53` is a highly available and scalable Domain Name System (DNS) web service. Route 53 connects user requests to internet applications running on AWS or on-premises. In essence, a DNS turns domain names into IP addresses, allowing browsers to access websites and other internet resources.

**Global Routing**: Route end users to your site reliably with globally dispersed Domain Name System (DNS) servers and automatic scaling.

**Routing Policies**: Customise your DNS routing policies to reduce latency, improve application availability, and maintain compliance.

**Readiness Checks**: Ensure your resources across Availability Zones or Regions are continually audited for recovery readiness.

**IP-Based Routing**: Fine-tune your DNS routing approach based on the Classless Inter-Domain Routing (CIDR) block that the query-originating IP address belongs to.

## Connecting Namecheap Domain to Route 53

I would assume you have already purchased a domain from Namecheap or any other provider.

### Created a Hosted Zone in Route53 and Redirect NameCheap Domain to AWS Route53.

- In the Route 53 dashboard click on Create Hosted Zone and input your domain name in the first field then click Create Hosted Zone. Ensure you input the domain name without prefixes.
  
- `example.com`

- Next, navigate to your Namecheap dashboard and click manage on the domain name you wish to connect.
IN Left Sidebar -> Click on `Domain List` -> Click on Domain

- Click the dropdown on name servers and select custom DNS.

- Go to Route53 hosted zone dashboard Click the dropdown on name servers and select custom DNS.

## Certificate Manager

AWS Certificate Manager (ACM) is a service that lets you easily provision, manage, and deploy public SSL certificates using AWS services.

Before we begin, always make sure you are in the US-East-1 or North Virginia region! Because that’s where the edge location is and most of your cloud services will require that your certificates are installed on US-East-1 or North Virginia region.

Then, press the Get Started button under the Provision Certificates section. Here, we can request a public certificate. We have to provide a domain name and any sub-domains of your domain.

- we have to validate the ownership of this domain using one of two options, DNS validation or Email validation.

- If you are using a DNS validation, which is a bit faster, you have to provide some DNS records.

- The DNS provider, in this case, is Route 53, so we can simply hit the button called, “Create a record in Route 53.” It will automatically create the necessary DNS records for us. Similarly, we can do this for every domain.

- After this step, if you go back to the Route 53 console and refresh, you can find a new CNAME entry.

- Returning to the ACM console, it's perfectly fine if the validation status is pending. After a few minutes, we should have an active status.

- One more thing here to add is the name tags. Remember, in our serverless application codes, we added certificateName. We copy that name and edit the name tags with the name we put in the certificate name. That will set the certificate name for us.

### Update Load Balancer `Listeners and routing` part
- Protocol `HTTPS` -> Port `443` -> Target Group
- Also, `Default SSL/TLS server certificate` -> From `ACM` -> Select from `AWS Certificate Manager`

# Phase 5: Application demo


Reference

[For CI/CD](https://github.com/darjidhruv26/AWS-CICD-Pipeline?tab=readme-ov-file#create-ec2-instance)

[From AWS Blogs](https://aws.amazon.com/blogs/devops/building-an-end-to-end-kubernetes-based-devsecops-software-factory-on-aws/)

[Snyk integration in CI/CD](https://docs.snyk.io/integrate-with-snyk/snyk-ci-cd-integrations/aws-codepipeline-integration-by-adding-a-snyk-scan-stage)

[Snyk Docs](https://snyk.io/blog/automate-vulnerability-scanning-in-aws-codepipeline-with-snyk/)

[Isaac Adepitan's Blog for Namecheap to Route53](https://dev.to/1zyik/how-to-connect-your-namecheap-domain-to-route-53-2i8)

[Namecheap Docs](https://www.namecheap.com/support/knowledgebase/article.aspx/10371/2208/how-do-i-link-my-domain-to-amazon-web-services/)
