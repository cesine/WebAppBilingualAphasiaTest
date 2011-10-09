#!/usr/bin

git checkout laptopserver
git merge master
git add .
git commit -m "server adding files"
git checkout master
git merge laptopserver
