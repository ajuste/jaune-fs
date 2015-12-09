/**
 * @file   Source code for file system manager.
 * @author Alvaro Juste <juste.alvaro@gmail.com>
 */
"use strict";

// 3rd
const _isFunction = require("lodash").isFunction;
const _isBoolean  = require("lodash").isBoolean;

// jaune
const _reflection = require("jaune-util").Reflection;

const Enums = {
  ReadResult : {
    Success : 0,
    InvalidPath : 1,
    NotFound : 2,
    InvalidResourceType : 3,
    NotModified : 4
  }
};
/**
 * @constant Environment section name for file system connections
 */
const FILESYSTEM_CONNECTIONS = "jaune.fileSystem.connections";

/**
* @function Gets result for reading
* @param    {Number} code Error code
* @param    {Stream} stream The stream
* @param    {Object} stat File stat
*/
const __getReadResult = function(code, stream, stat) {
  return { code : code, stream : stream, stat : stat };
};

/**
 * @class File system manager.
 */
const FileSystemManager = function(env) {
  this.modules = {};
  this.env     = env;
};

/**
 * @function Get module by key
 * @param    {String} key The module key
 * @returns  {Object} The module
 */
FileSystemManager.prototype.getModule = function(key) {

  var connection = null;

  if (!this.modules[key]) {
    connection        = this.env.getEnvProperty(FILESYSTEM_CONNECTIONS, key);
    this.modules[key] = _reflection.createInstance(connection.type, [connection]);
  }
  return this.modules[key];
},

/**
* @function Read a file
* @param    {Object} module Module that is going to read
* @param    {Object} args Arguments
*/
FileSystemManager.prototype.read = function* (module, args) {

  var fstat = null;

  if (args.path.indexOf("./") !== -1) {
    return __getReadResult(Enums.ReadResult.InvalidPath)
  }
  if (!(yield module.exists(args.path))) {
    return __getReadResult(Enums.ReadResult.NotFound);
  }
  fstat = yield module.stat(args.path);

  if (fstat.isDirectory()){
    return __getReadResult(Enums.ReadResult.InvalidResourceType);
  }
  if (_isFunction(args.checkCache) && args.checkCache(fstat)) {
    return __getReadResult(Enums.ReadResult.NotModified);
  }
  return __getReadResult(Enums.ReadResult.Success, (yield module.readFile(args.path)), fstat);
};

module.exports = {
  Manager    : FileSystemManager,
  ReadResult : Enums.ReadResult
};
