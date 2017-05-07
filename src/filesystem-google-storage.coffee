###*
 * @file   NodeJS module that implements file system handler based on Google
 *         storage
 * @author Alvaro Juste <juste.alvaro@gmail.com>
###

"use strict"

mime = require "mime"
Stream = require "stream"

###*
 * @class File system constructor.
 * @param {object} connection Accepts the connection to the file system.
###
class GoogleStorageClient

  ###*
  * @constructor Constructs a new filesystem connection to google cloud storage
  * @param {Object} connection The connection which contains the following data
  *                 {
  *                   credentials: {client_email, private_key},
  *                   projectId,
  *                   bucketName,
  *                 }
  ###
  constructor: (@connection) ->

    @storage = require('@google-cloud/storage') @connection
    @bucket = @storage.bucket @connection.bucketName

  file: (path) -> @bucket.file path

  ###*
   * @function Move a file
   * @param    {String} source Source key
   * @param    {String} target Targett key
   * @returns  {Promise}
  ###
  move: (source, target) ->

    new Promise (res, rej) =>

      @file source
        .move target, (err) -> if err? then rej err else res()

  ###*
   * @function Writes a file bucket
   * @param    {String} path Is the key
   * @param    {Buffer|String|Stream} data Data to be written into file.
   * @param    {Object} options Extra options
   * @param    {String}
   * @returns  {Promise}
  ###
  writeFile : (path, data) ->

    new Promise (res, rej) =>

      inputStream =
        @file path
          .createWriteStream metadata: contentType: mime.lookup path
          .on 'error', rej
          .on 'finish', res

      if data instanceof Stream
        data.pipe inputStream
      else
        inputStream.end data

  ###*
   * @function Reads an object
   * @param    {String} path The key of the object
   * @returns  {Stream}
  ###
  readFile : (path) -> @file(path).createReadStream()

  ###*
   * @function Checks if file exists.
   * @param    {path} string The key
   * @returns  {Promise}
  ###
  exists : (path) ->

    new Promise (res, rej) =>

      @file(path).exists (err, exists) -> if err? then rej err else res exists

  ###
   * @function Copies a path into another.
   * @param    {from} string The source key.
   * @param    {to} string The destination key.
   * @returns  {Promise}
  ###
  copy : (from, to) ->

    new Promise (res, rej) =>

      @file(from).copy to, (err, exists) -> if err? then rej err else res()

  ###*
   * @function Removes a file
   * @param    {String} path The file to be removed
   * @param    {Boolean} [options.absolute] When true the path is not
   *           converted to absolute.
   * @returns  {Promise}
  ###
  removeFile : (path) ->

    new Promise (res, rej) =>

      @file path
        .delete (err) ->
          if err? then rej err else res()

  ###*
   * @function Retrieves the STAT object for a specified path.
   * @param {path} string The source path.
   * @param {function} cb Standard callback function.
   * @returns  {Promise}
  ###
  stat : (path) ->

    new Promise (res, rej) =>
      @file path
        .getMetadata (err, meta) ->
          if err? then rej err else res new Stat meta

###*
 * @class Stat wrapper
 * @param {object} head The head object
###
class Stat

  constructor: (@meta) ->

  ###*
   * @function Checks if STAT is a directory.
  ###
  isDirectory : -> no

  ###*
   * @function Returns the MIME type of file.
  ###
  getMime : -> @meta.contentType

  ###*
   * @function Get size of file in bytes
  ###
  getSize : -> @meta.size

module.exports = {GoogleStorageClient}
