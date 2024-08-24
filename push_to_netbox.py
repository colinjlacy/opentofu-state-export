#! /usr/bin/python3

import requests
import json
import fileinput

# your API key
netbox_api_key = ""
# your Netbox host
netbox_host = ""
# http or https
netbox_proto = ""
netbox_url = f'{netbox_proto}://{netbox_host}/api'


def get_std_in():
  input = ""
  for line in fileinput.input():
      input += line
  return json.loads(input)

    
def thing_getter(thing_name, attr_name, attr_value, path="/dcim/"):
    url = netbox_url + path + thing_name + "/?" + attr_name + "=" + attr_value
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Token " + netbox_api_key
    }
    response = requests.get(url, headers=headers)
    data = response.json()
    if data["count"] == 0:
        return None
    return data["results"][0]

def thing_poster(thing_name, key_attr, data, path="/dcim/"):
    existing = thing_getter(thing_name, key_attr, data[key_attr], path)
    if existing:
        return existing
    url = netbox_url + path + thing_name + "/"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Token " + netbox_api_key
    }
    response = requests.post(url, headers=headers, data=json.dumps([data]))
    if response.status_code != 201:
        print("Error posting to Netbox: " + response.text)
        return
    return response.json()[0]

def post_netbox_site(data, key_attr="name"):
    return thing_poster("sites", key_attr, data)

def post_netbox_device_role(data, key_attr="name"):
    return thing_poster("device-roles", key_attr, data)

def post_netbox_manufacturer(data, key_attr="name"):
    return thing_poster("manufacturers", key_attr, data)

def post_netbox_device_type(data, key_attr="model"):
    return thing_poster("device-types", key_attr, data)

def post_ip_address(data, key_attr="address"):
    return thing_poster("ip-addresses", key_attr, data, "/ipam/")

def post_netbox_device(data, key_attr="name"):
    return thing_poster("devices", key_attr, data)

def post_netbox_interface(data, key_attr="name"):
    return thing_poster("interfaces", key_attr, data)

def set_primary_ip(device_id, ip_id):
    url = netbox_url + "/dcim/devices/" + str(device_id) + "/"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Token " + netbox_api_key
    }
    response = requests.patch(url, headers=headers, data=json.dumps({"primary_ip4": ip_id}))
    if response.status_code != 200:
        print("Error setting primary IP: " + response.text)
    return
    

def main():
    input = get_std_in()

    manufacturer = None

    for resource in input["values"]["root_module"]["resources"]:
        resource_type = resource["type"]
        resource_name = resource["name"]
        resource_attrs = resource["values"]

        # If I were building this for production, I'd be a much more careful here.
        # But it seems that data blocks are always first in the list of resources.
        # So for PoC purposes, this will/should work.
        # I also wouldn't assume that there would only be one AMI for all instances.
        # Again, PoC.
        if resource_type == "aws_ami":
            manufacturer = post_netbox_manufacturer({
                "name": resource["values"]["owners"][0].upper(),
                "slug": resource["values"]["owners"][0]
            })


        if resource_type == "aws_instance":
            site = post_netbox_site({
                "name": resource_attrs["tags"]["Site"],
                "slug": resource_attrs["tags"]["Site"],
                "status": "active"
            })
            device_role = post_netbox_device_role({
                "name": resource_attrs["tags"]["DeviceRoleName"],
                "slug": resource_attrs["tags"]["DeviceRoleName"],
                "color": resource_attrs["tags"]["DeviceRoleColor"]
            })
            device_type = post_netbox_device_type({
                "manufacturer": manufacturer["id"],
                "model": resource_attrs["instance_type"],
                "slug": resource_attrs["instance_type"].replace(".", "-")
            })
            device = post_netbox_device({
                "name": resource_name,
                "site": site["id"],
                "role": device_role["id"],
                "device_type": device_type["id"],
                "status": "active",
            })
            interface = post_netbox_interface({
                "name": (resource_name.lower().replace(" ", "-")) + "_eth0",
                "device": device["id"],
                "type": "bridge"
            })
            ip = post_ip_address({
                "address": resource_attrs["public_ip"] if resource_attrs["public_ip"] != "" else resource_attrs["private_ip"],
                "description": "public" if resource_attrs["public_ip"] != "" else "private",
                "assigned_object_id": interface["id"],
                "assigned_object_type": "dcim.interface"
            })
            set_primary_ip(device["id"], ip["id"])


if __name__ == "__main__":
  main()
