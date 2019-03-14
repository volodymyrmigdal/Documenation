require( 'wTools' );
let arrayify = require('array-back')
// let state = require('dmd/lib/state.js') //access to templateData

let _ = _global_.wTools;
let jsDoc2Md = _global_.jsdoc2md;

_.include( 'wPathFundamentals' )

function methodSignature( context )
{
  let result = _.arrayAs( context.params || [] );

  result = result.filter( ( param ) =>
  {
    return param.name && !/\./.test(param.name)
  });

  result = result.map(( param ) =>
  {
    if (param.variable)
    {
      return param.optional ? '[...' + param.name + ']' : '...' + param.name
    }
    else
    {
      return param.optional ? '[' + param.name + ']' : param.name
    }
  });

  result = result.join(', ');
  result = '( ' + result + ' )';

  return result;
}

function saveToSearchIndex()
{
  let id = this.name;

  if( this.memberof )
  id = this.memberof + '.' + this.name;

  let url = `/#/Reference/${jsDoc2Md.currentFile}?id=${this.name}`;
  jsDoc2Md.searchIndex[ id ] = { title : id, url : url };
}

function logThis()
{
  console.log( this );
}

exports.methodSignature = methodSignature;
exports.saveToSearchIndex = saveToSearchIndex;
exports.logThis = logThis;