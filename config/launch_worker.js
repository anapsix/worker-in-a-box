#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const Cloudworker = require('@dollarshaveclub/cloudworker');

const workerScript = fs.readFileSync(path.resolve(__dirname, './worker.js'), 'utf8');

// const store = new Cloudworker.KeyValueStore(path.resolve(__dirname, './my_store.json'));

const worker = new Cloudworker(workerScript, {
  debug: true,
  // bindings: {
  //   'MY_STORE': store
  // }
});
worker.listen()
