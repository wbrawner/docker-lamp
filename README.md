Docker LAMP Stack for Magento
========================================

To get started, first [download and install Docker](https://docs.docker.com/docker-for-windows/).

From the docker-lamp directory, you can run

`docker-compose up -d`

This will take some time because Docker will have to fetch and configure the image for the LAMP stack.

Once you have your Docker machine running, you can place your files in the public_html folder. The other folders contain configuration files, so it's not recommended to add files to them or modify them in any way.

By using either the container id or its name, you can connect to them with the following command:

`docker exec -it CONTAINER_NAME/ID /bin/bash`

Replace CONTAINER_NAME/ID with the name or id of the container you'd like to connect to, and you will be dropped into a bash environment where you can run commands like importing a large database into MySQL or running composer or magerun (both of which are already installed and ready to use.)

So, to run a composer installation, you would need to first run

`docker exec -it dockerlamp_app_1 /bin/bash`

to gain access to the shell, and then you could cd into the correct directory and run your composer install command. From here, you could also run MySQL, vim, etc.

DISCLAIMER:

This Docker machine should under NO circumstances, be used in a production environment. This is solely intended for local development, and has numerous security concerns that would need to be addressed prior to being a feasible production candidate. You have been warned.
