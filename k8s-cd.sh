#!/bin/bash

sed -i "s/lab-php:0.1/lab-php:0.2/g" /lab/php.yml
kubectl apply -f /lab/php.yml
