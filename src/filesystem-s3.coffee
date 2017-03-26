###*
 * @file   NodeJS module that implements file system handler based on S3 Buckets
 * @author Alvaro Juste <juste.alvaro@gmail.com>
###

"use strict"

mime = require "mime"

###*
 * @class File system constructor.
 * @param {object} connection Accepts the connection to the file system.
###
class FsClient

  constructor: (@connection) ->

    AWS = require 'aws-sdk'

    # this will have the following format:
    # { "accessKeyId": <YOUR_ACCESS_KEY_ID>, "secretAccessKey": <YOUR_SECRET_ACCESS_KEY>, "region": "us-east-1" }
    @s3 = new AWS.S3 @connection

  ###*
   * @function Move a file
   * @param    {String} source Source key
   * @param    {String} target Targett key
  ###
  move: (source, target) ->

    params = Bucket: @connection.bucket, Key: source

    @copy source, target
    .then new Promise(res, rej) ->

      s3.deleteObject params, (err) -> if err? then rej err else res()

  ###*
   * @function Writes a file bucket
   * @param    {String} path Is the key
   * @param    {Buffer|String|Stream} data Data to be written into file.
  ###
  writeFile : (path, data) ->

    new Promise (res, rej) ->

      params = Bucket: @connection.bucket, Key: path, Body: data

      s3.putObject params, (err, data) -> if err? then rej err else res data

  ###*
   * @function Reads an object
   * @param    {String} path The key of the object
  ###
  readFile : (path) ->

    new Promise (res, rej) ->

      params = Bucket: @connection.bucket, Key: path

      s3.getObject params, (err, data) -> if err? then rej err else res data

  ###*
   * @function Checks if file exists.
   * @param    {path} string The key
  ###
  exists : (path) ->
    new Promise (res, rej) =>
      @stat path, (err, data) ->
        if err?
          return res no if err.code is 'NotFound'
          return rej err
        res yes

  ###
   * @function Copies a path into another.
   * @param    {from} string The source key.
   * @param    {to} string The destination key.
  ###
  copy : (from, to) ->

    params = Bucket: @connection.bucket, Key: target, CopySource: source

    new Promise (res, rej) ->
      s3.copyObject params, (err) -> if err? then rej err else res data

  ###*
   * @function Removes a file
   * @param    {String} path The file to be removed
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
  ###
  removeFile : (path, options = {absolue: no}) ->

    params = Bucket: @connection.bucket, Key: target, Key: path

    new Promise (res, rej) ->
      s3.deleteObject params, (err, data) -> if err? then rej err else res data

  ###*
   * @function Retrieves the STAT object for a specified path.
   * @param {path} string The source path.
   * @param {function} cb Standard callback function.
  ###
  stat : (path, cb) ->

    new Promise (res, rej) ->
      s3.headObject params, (err, data) ->
        s3.copyObject params, (err) ->
          if err?
            return res no if err.code is 'NotFound'
            return rej err
          res yes

###*
 * @class Stat wrapper
 * @param {object} head The head object
###
class Stat

  constructor (@head) ->

  ###*
   * @function Checks if STAT is a directory.
  ###
  isDirectory : -> no

  ###*
   * @function Returns the MIME type of file.
  ###
  getMime : -> @head.ContentEncoding

module.exports = {
  S3Bucket: FsClient
}
