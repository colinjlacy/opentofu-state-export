# OpenTofu State Export

This repo is a PoC that shows how you can use the `tofu show` or `terraform show` command to export the state of your infrastructure, and insert it into downstream data source.  In this PoC, we're pushing state data into [NetBox](https://netboxlabs.com/docs/netbox/en/stable/) using the [v4 API](https://netboxlabs.com/docs/netbox/en/stable/integrations/rest-api/).

## Prerequisites

Before you can do much with the files in this repo, you'll need:

- Either OpenTofu or Terraform installed locally
  - If you're using Terraform, wherever you see the `tofu` command, you'll use the `terraform`
- A running instance of NetBox and an API token
  - I used the open source [netbox-docker](https://github.com/netbox-community/netbox-docker) repo to run it locally
  - This came with all of the dependencies as well
  - To create an admin user, SSH into the running `netbox-docker-netbox-1` container and run `$ /opt/netbox/netbox/manage.py createsuperuser`
- An AWS account that you can `tofu`/`terraform` some stuff into

## About Terraform

Since I built this with OpenTofu 1.8.1, I included the `encryption` block in `main.tf`. If you're going to use Terraform to try this out, you'll have to remove that block, as it's incompatible with Terraform for...[reasons](https://developer.hashicorp.com/terraform/language/state/sensitive-data).

## The Tofu

The `.tf` files in this repo build out:

- a VPC in `us-west-2` with one public subnet and three private subnets
- an EC2 instance is deployed in each subnet
- an Elastic IP so that you can reach the instance in the public subnet
- an assigned private IP for each of the instances in the private subnets

If you have an AWS account configured via the AWS CLI, you can build out your infrastructure by running:

```sh
$ tofu init
$ tofu plan -var-file=vars/development.tfvars -out=plan
$ tofu apply plan
```

Once that's done, you can get to the actual point of this repo...

## Pushing Infrastructure Data to NetBox

Once you have your infrastructure set up, you can see a JSON representation of it by running:

```sh
$ tofu show -json terraform.state
```

The output will be a big string of sensative data representing everyhting in your state file. Even if you used [state file ecryption](https://opentofu.org/docs/language/state/encryption/), OpenTofu will decrypt the state before printing it. So be very careful about what you do with the output.

The file `push_to_netbox.py` reads from `os.StdIn` and parses the JSON output of `tofu show` to make a series of API calls into the NetBox API to create records in each of the corresponding data resources.

Before we can use it, we'll need to set up our environment:

```sh
# new venv
$ python3 -m venv venv     
# activate said venv
$ source venv/bin/activate
# install dependencies
$ pip3 install -r requirements.txt
```

Awesome. Now we just need to plug in a few strings to set up API requests into your NetBox instance, starting on line 7:

```python
# your API key
netbox_api_key = ""
# your Netbox host
netbox_host = ""
# http or https
netbox_proto = ""
```

With those values added, you should be able to run the following:

```sh
$ tofu show -json terraform.tfstate | python3 push_to_netbox.py
```

That command (or pair of commands) will pipe the output from `tofu show` into `os.StdIn` for `push_to_netbox.py` to ingest when it runs, which it will do as soon as the state is finished printing.

The result will be to push all of that data into NetBox. If it runs successfully, you can check by navigating to `<your-netbox-instance>/dcim/devices/` in the browser.  You should see four new instances added to the `us-west-2_tofu-vpc` site, with IP addresses assigned to all of them.

## Caveats

This was a pure proof-of-concept endeavor. This will post each resource, and on subsequent runs, check to ensure that the resource exists. If there are updates to any of the resources, they will not be tracked. Again, this was a PoC, so the goal was not to make the script fully-featured.

Also, it is indeed a script. It was made for these specific OpenTofu resources in this specific OpenTofu configuration. I would not suggest that the current state of `push_to_netbox.py` can/should be used in your environment.

I **would**, however suggest experimenting with your own script. As mentioned at the top, this doesn't have to be pushed to NetBox - you could push it to any other database following any other remapping of the state data.
