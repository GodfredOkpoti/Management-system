#!/bin/bash

docker stop system
docker rm system
docker image rm godfred123/management-system-app:latest 