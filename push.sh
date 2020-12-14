#!/bin/bash
set -ex

cd public
git add . -A
git commit -m "update blog `date`"
git push origin master ;

