#!/bin/bash
set -ex

cd public
git add . 
git commit -m "update blog `date`"
git push origin 

