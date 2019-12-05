#!/bin/bash

if test -f ".env.default"; then
  export $(cat .env.default | grep -v ^# | xargs);
fi
if test -f ".env"; then
  export $(cat .env | grep -v ^# | xargs);
fi

iex -S mix
