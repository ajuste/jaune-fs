###*
 * @file   Source code for file system manager.
 * @author Alvaro Juste <juste.alvaro@gmail.com>
###
"use strict"

# 3rd
reflection = require("jaune-util").Reflection;

Enums =
  ReadResult :
    Success : 0,
    InvalidPath : 1,
    NotFound : 2,
    InvalidResourceType : 3,
    NotModified : 4

###*
 * @constant Environment section name for file system connections
###
FILESYSTEM_CONNECTIONS = "jaune.fileSystem.connections";

###*
* @function Gets result for reading
* @param    {Number} code Error code
* @param    {Stream} stream The stream
* @param    {Object} stat File stat
###
getReadResult = (code, stream, stat) -> {code, stream, stat}

###*
 * @class File system manager.
###
class FileSystemManager
  constructor: (@env) ->
    @modules = {}

  ###*
   * @function Get module by key
   * @param    {String} key The module key
   * @returns  {Object} The module
  ###
  getModule: (key) ->

    connection = null

    if not @modules[key]
      connection = @env.getEnvProperty FILESYSTEM_CONNECTIONS, key
      @modules[key] = reflection.createInstance connection.type, [connection]

    @modules[key]

  ###*
  * @function Read a file
  * @param    {Object} module Module that is going to read
  * @param    {Object} args Arguments
  ###
  read: (module, args) ->

    fstat = null

    {
      path
      checkCache
    } = args

    if path.indexOf "./" isnt -1
      getReadResult Enums.ReadResult.InvalidPath

    if not yield module.exists path
      getReadResult Enums.ReadResult.NotFound

    fstat = yield module.stat path

    if fstat.isDirectory()
      return getReadResult Enums.ReadResult.InvalidResourceType

    if typeof checkCache is 'function' and not args.checkCache fstat
      return getReadResult Enums.ReadResult.NotModified

    getReadResult Enums.ReadResult.Success, (yield module.readFile(path)), fstat


module.exports =
  Manager    : FileSystemManager
  ReadResult : Enums.ReadResult
