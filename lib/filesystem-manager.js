
/**
 * @file   Source code for file system manager.
 * @author Alvaro Juste <juste.alvaro@gmail.com>
 */
"use strict";
var Enums, FILESYSTEM_CONNECTIONS, FileSystemManager, getReadResult, reflection;

reflection = require("jaune-util").Reflection;

Enums = {
  ReadResult: {
    Success: 0,
    InvalidPath: 1,
    NotFound: 2,
    InvalidResourceType: 3,
    NotModified: 4
  }
};


/**
 * @constant Environment section name for file system connections
 */

FILESYSTEM_CONNECTIONS = "jaune.fileSystem.connections";


/**
* @function Gets result for reading
* @param    {Number} code Error code
* @param    {Stream} stream The stream
* @param    {Object} stat File stat
 */

getReadResult = function(code, stream, stat) {
  return {
    code: code,
    stream: stream,
    stat: stat
  };
};


/**
 * @class File system manager.
 */

FileSystemManager = (function() {
  function FileSystemManager(env) {
    this.env = env;
    this.modules = {};
  }


  /**
   * @function Get module by key
   * @param    {String} key The module key
   * @returns  {Object} The module
   */

  FileSystemManager.prototype.getModule = function(key) {
    var connection;
    connection = null;
    if (!this.modules[key]) {
      connection = this.env.getEnvProperty(FILESYSTEM_CONNECTIONS, key);
      this.modules[key] = reflection.createInstance(connection.type, [connection]);
    }
    return this.modules[key];
  };


  /**
  * @function Read a file
  * @param    {Object} module Module that is going to read
  * @param    {Object} args Arguments
   */

  FileSystemManager.prototype.read = function*(module, args) {
    var checkCache, fstat, path;
    fstat = null;
    path = args.path, checkCache = args.checkCache;
    if (path.indexOf("./" !== -1)) {
      getReadResult(Enums.ReadResult.InvalidPath);
    }
    if (!(yield module.exists(path))) {
      getReadResult(Enums.ReadResult.NotFound);
    }
    fstat = (yield module.stat(path));
    if (fstat.isDirectory()) {
      return getReadResult(Enums.ReadResult.InvalidResourceType);
    }
    if (typeof checkCache === 'function' && !args.checkCache(fstat)) {
      return getReadResult(Enums.ReadResult.NotModified);
    }
    return getReadResult(Enums.ReadResult.Success, (yield module.readFile(path)), fstat);
  };

  return FileSystemManager;

})();

module.exports = {
  Manager: FileSystemManager,
  ReadResult: Enums.ReadResult
};
