#!/bin/bash

sample(){
  echo one
  echo two
}

function sample1(){
  echo three
  echo four
}

sample
sample1

sample2(){
  echo first argument =$1
  echo no of arguments=$#
}
sample2 xyz 123