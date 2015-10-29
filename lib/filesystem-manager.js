/**
 * @file   Source code for file system manager.
 * @author Alvaro Juste <juste.alvaro@gmail.com>
 */
"use strict";

const _isFunction     = require("lodash").isFunction;
const _Reflection     = require("jaune-util").Reflection;
const _getEnvProperty = require("jaune-env").getEnvProperty;

const Enums       = {
  ReadResult : {
    Success : 0,
    InvalidPath : 1,
    NotFound : 2,
    InvalidResourceType : 3,
    NotModified : 4
  }
};
const FILESYSTEM_CONNECTIONS = "fileSystem.connections";


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
 const FileSystemManager = function() {
  this.modules     = {};
  this.environment = GetEnv();
};
/**
 * Prototype
 */
FileSystemManager.prototype = {
  /**
   * @function Get module by key
   * @param    {String} key The module key
   * @returns  {Object} The module
   */
  getModule : function(key) {

    var connection = null;

    if (!this.modules[key]) {
      connection = _getEnvProperty(FILESYSTEM_CONNECTIONS, key);
      this.modules[key] = _Reflection.createInstance(connection.type, [connection]);
    }
    return this.modules[key];
  },
  /**
  * @function Read a file
  * @param    {Object} module Module that is going to read
  * @param    {Object} args Arguments
  */
  read : function* (module, args) {

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
  }
};
module.exports = function(env) {
  Manager    : new FileSystemManager(env),
  ReadResult : Enums.ReadResult
};
