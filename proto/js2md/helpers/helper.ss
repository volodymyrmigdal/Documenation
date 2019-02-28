require( 'wTools' );
let arrayify = require('array-back')

let _ = _global_.wTools;

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

exports.methodSignature = methodSignature;