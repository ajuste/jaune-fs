const _extend  = require("lodash").extend;
const _exports = {};

_extend(_exports, require("./filesystem-manager"));
_extend(_exports, require("./filesystem-fs"));
_extend(_exports, require("./filesystem-dropbox"));

module.exports = _exports;
