# MIDS-W251-SCALING-UP

###### Author: Rajesh Thallam
###### Scaling Up: Assignment/Homework 4 - mumbler
###### Source: https://github.com/RajeshThallam/coursework/tree/master/week4/hw/the_mumbler 

## Instructions to Run
Login to the cluster

user: xxxx

password: xxxxxxxx

host: 127.0.0.1

There are two scripts

1. Pre-processing script that includes downloading files and pre-processing files for mumbler to run quicker.

   Currently, I have the download functionality disabled.

    ```
    To run pre-processor
      cd /gpfs/gpfsfpo/scripts
      nohup /gpfs/gpfsfpo/scripts/main.wrapper.sh &
    ```

2. Mumbler accepts starting word and nax words as parameter

    ```
    To run mumbler
      cd /gpfs/gpfsfpo/scripts
      ./mumbler.sh WORD COUNT
    ```     

   NOTE: Both the parameters are mandatory to run

Logs are available under /gpfs/gpfsfpo/logs