import subprocess

import click
import pyrax

import requests

from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

server = None


@click.command()
@click.option(
    '--name', prompt='Server name',
    help='The name for the new server'
)
@click.option(
    '--keypair',
    default=None,
    help='Keypair to inject'
)
def create_server(name, keypair):
    cmd = (
        'rack servers instance create --name="{name}" --flavor-id=io1-15'
        ' --block-device source-type=image,'
        'source-id=1d3ea64f-1ead-4042-8cb6-8ceb523b6149,'
        'destination-type=volume,volume-size=150'
    ).format(name=name)

    if keypair:
        cmd += ' --keypair={keypair}'.format(keypair)

    print('Creating server {name}'.format(name=name))
    print(cmd)
    print(cmd.split(' '))
    subprocess.run(cmd.split(' '))


def get_server_status(name):
    pyrax.set_credential_file("/Users/neill/pyraxcreds")
    cs = pyrax.cloudservers
    print(cs.servers.list())


def create_server2(name, keypair):
    pyrax.set_credential_file("/Users/neill/pyraxcreds")
    nova = pyrax.cloudservers
    bdm = {
        'source_type': 'image',
        'uuid': '1d3ea64f-1ead-4042-8cb6-8ceb523b6149',
        'destination_type': 'volume',
        'volume_size': '150',
        'boot_index': '0'
    }

    my_server = nova.servers.create(
        name=name,
        image=None,
        flavor='io1-15',
        key_name=keypair,
        block_device_mapping_v2=[bdm]
    )

    print(my_server.status)


def main():
    # create_server()
    # get_server_status('test-xx')
    create_server2('test-xx', 'neill')

main()
