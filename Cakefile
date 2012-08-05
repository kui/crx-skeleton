# -*- coding:utf-8-unix; mode:coffee; -*-

# commands ####################################################################
MOCHA = 'node_modules/.bin/mocha'
COFFEE = 'node_modules/.bin/coffee'
GOOGLE_CHROME = 'google-chrome'

# files or dirs ###############################################################
SOURCE_DIR = 'src'
TEST_DIR = 'test'
PEM_FILE = "#{SOURCE_DIR}.pem"
MANIFEST_COFFEE = "#{SOURCE_DIR}/manifest.coffee"
MANIFEST_JSON = "#{SOURCE_DIR}/manifest.json"

# functions ###################################################################
CoffeeScript = require 'coffee-script'
cp = require 'child_process'
util = require 'util'
fs = require 'fs'

log = (o) ->
  util.log o

eachLine = (str, cb) ->
  cb line for line in str.split /\r?\n/

logEachLine = (str) ->
  eachLine str, (line) -> log line

logExecResult = (err, stdout, stderr) ->
  logEachLine stdout if stdout
  logEachLine stderr if stderr

  if err
    log '=> Fail'
    process.exit 1
  else
    log '=> Success'

exec = (cmd, cb) ->
  log '$ '+cmd
  cp.exec cmd, cb

listPathsByExt = (ext, p) ->
  return [] if p.match("/(?:node_modules|.git)$")

  list = []
  stats = fs.statSync p

  if stats.isFile()
    list.push p if p.match "\\.#{ext}$"

  else if stats.isDirectory()
    for child in fs.readdirSync p
      list = list.concat listPathsByExt ext, "#{p}/#{child}"

  list

# tasks #######################################################################

task 'build', 'build crx', ->
  mftCmd = "#{COFFEE} -p -b #{MANIFEST_COFFEE}"
  cmplCmd = "#{COFFEE} -c #{SOURCE_DIR}"
  pkgCmd = "#{GOOGLE_CHROME} --no-message-box --pack-extension=#{SOURCE_DIR}"
  pkgCmd += " --pack-extension-key=#{PEM_FILE}" if fs.existsSync PEM_FILE

  cmplCb = (err, stdout, stderr) ->
    logExecResult err, stdout, stderr
    exec pkgCmd, pkgCb

  pkgCb = (err, stdout, stderr) ->
    log 'Error: try to package manually on GUI' if err
    logExecResult err, stdout, stderr

  # generate manifest.json
  manifest = fs.readFileSync MANIFEST_COFFEE, 'utf8'
  json = JSON.stringify CoffeeScript.eval manifest
  fs.writeFileSync MANIFEST_JSON, json

  exec cmplCmd, cmplCb


task 'clean', "Remove all generated files", ->
  targets = listPathsByExt 'crx', '.'
  targets = targets.concat listPathsByExt 'js', '.'
  targets.push MANIFEST_JSON if fs.existsSync MANIFEST_JSON

  if targets.length == 0
    log 'not found files to remove'
    return

  cmd = "rm #{targets.join ' '}"

  exec cmd, logExecResult

task 'test', "Run all unit tests on #{TEST_DIR}", ->
  for testFile in fs.readdirSync TEST_DIR
    continue unless m = testFile.match /^(.*)_test.coffee$/
    testFile = "#{TEST_DIR}/#{m[0]}"
    log "test: #{testFile}"

    srcFile = "#{SOURCE_DIR}/#{m[1]}.coffee"
    unless fs.existsSync srcFile
      log "not found a src file (#{srcFile})"
      continue
    log "src:  #{srcFile}"

    jsFile = "#{TEST_DIR}/#{m[1]}_test.js"
    cmplCmd = "#{COFFEE} --compile --join #{jsFile} #{srcFile} #{testFile}"
    testCmd = "#{MOCHA} #{jsFile}"

    exec cmplCmd, (err, stdout, stderr) ->
      logExecResult err, stdout, stderr
      exec testCmd, logExecResult

