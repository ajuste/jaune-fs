###*
 * @file   NodeJS module that implements file system handler based on local file system.
 * @author Alvaro Juste <juste.alvaro@gmail.com>
###

"use strict"

mime = require "mime"
ncp = require "ncp"
{
  join
} = require "path"
{
  createReadStream
  createWriteStream
  exists
  rename
  readFile
  stat
  writeFile
  unlink
} = require "fs"

stream = require "stream"

###*
 * @function Convert to absolute path
 * @param    {String} path The path
 * @returns  {String} Converted path
###
convertPathToAbsolute = (path) -> join process.cwd(), path

###*
 * @class File system constructor.
 * @param {object} connection Accepts the connection to the file system.
###
class FSFileSystem

  constructor: (@connection) ->

  ###*
   * @function Move a file
   * @param    {String} source Source path
   * @param    {String} target Targett path
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
  ###
  move: (source, target, options = {absolute: no}) ->

    source = convertPathToAbsolute source unless options.absolute
    target = convertPathToAbsolute target unless options.absolute

    new Promise (res, rej) ->
      rename source, target, (err) ->
        return res() unless err?
        rej(err)

  ###*
   * @function Writes a file into file system.
   * @param    {String} path Where to write
   * @param    {Buffer|String|Stream} data Data to be written into file.
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
  ###
  writeFile : (path, data, options = {absolute: no}) ->

    path = convertPathToAbsolute path unless options.absolute

    new Promise (res, rej) ->

      if data instanceof stream

        write = createWriteStream(path);

        data
          .on "end", res
          .on "error", rej

        write
          .on "open", -> data.pipe write
          .on "error", rej

      else
        writeFile convertPathToAbsolute(path), data, (err) ->
          return rej err if err?
          res()

  ###*
   * @function Reads a file at the given path.
   * @param    {String} path The path to read file from.
   * @param    {String} [options.encoding] The encoding of the file
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
  ###
  readFile : (path, options = {encoding: "binary", absolute: no}) ->

    path = convertPathToAbsolute path unless options.absolute

    new Promise (res, rej) =>

      switch options.encoding

        when 'binary'

          @exists path, absolute: yes
            .then (exists) ->
              return res createReadStream path if exists
              rej new Error "file does not exists"
            .catch rej

        else
          readFile path, options.encoding, (err, data) ->
            return rej err if err?
            res data

  ###*
   * @function Checks if file exists.
   * @param    {path} string The path to file.
  ###
  exists : (path, options = {absolute: no}) ->

    path = convertPathToAbsolute path unless options.absolute

    new Promise (res, rej) ->
      exists path, (err, exists) ->
        return res err if err?
        res exists

  ###
   * @function Copies a path into another.
   * @param    {from} string The source path.
   * @param    {to} string The destination path.
  ###
  copy : (from, to) ->
    new Promise (res, rej) ->
      ncp convertPathToAbsolute(from), convertPathToAbsolute(to), (err) ->
        return rej err if err?
        res()

  ###*
   * @function Removes a file
   * @param    {String} path The file to be removed
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
  ###
  removeFile : (path, options = {absolue: no}) ->

    path = convertPathToAbsolute path unless options.absolute

    new Promise (res, rej) ->
      unlink path, (err) ->
        return rej err if err?
        res()

  ###*
   * @function Retrieves the STAT object for a specified path.
   * @param {path} string The source path.
   * @param {function} cb Standard callback function.
  ###
  stat : (path, options = {absolute: no}) ->

    path = convertPathToAbsolute path unless options.absolute

    new Promise (res, rej) ->
      stat convertPathToAbsolute(path), (err, stat) ->
        return rej err if err?
        res new FSClientStat path, stat

###*
 * @class Local file system STAT object wrapper.
 * @param {object} connection Accepts the connection to the file system.
 * @param {string} path The path of the STAT object.
###
class FSClientStat

  constructor: (@path, @stat) ->
    {@mtime, @size} = @stat

  ###*
   * @function Checks if STAT is a directory.
  ###
  isDirectory : -> @stat.isDirectory()

  ###*
   * @function Returns the MIME type of file.
  ###
  getMime : -> if @isDirectory() then "" else _mime.lookup(convertPathToAbsolute(@path))

module.exports = FsClient : FSFileSystem
