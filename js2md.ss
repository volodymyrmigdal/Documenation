( function _js2md_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( 'wFiles' );
  _.include( 'wExternalFundamentals' );
  var jsdoc2md = require( 'jsdoc-to-markdown' );
}

let _ = _global_.wTools;
let path = _.path;
let provider = _.fileProvider;

/*  */

function jsToMarkDownSingle( srcPath )
{
  let jsdocConf = path.resolve( 'jsdoc.json' );

  _.assert( provider.fileExists( jsdocConf ) );

  var files = provider.filesFind
  ({
    filePath : srcPath,
     recursive : 2,
     filter :
     {
       ends : [ '.s','.ss','.js' ],
       maskAll : { excludeAny : [ 'test', 'node_modules' ] }
     },
     includingDirs : 0,
     includingTerminals : 1,
     includingStem : 0,
     outputFormat : 'absolute'
  });

  if( !files.length )
  {
    logger.warn( 'No js files found at:', srcPath );
    return false;
  }

  let nativizedFiles = path.s.nativize( files );
  let nativizedConf = path.nativize( jsdocConf );

  let result = jsdoc2md.renderSync({ files : nativizedFiles, configure : nativizedConf });

  return result;
}

//

function jsToMarkDown()
{
  let args = _.appArgs();
  let submodulesPath = path.resolve( args.subject );
  let modules = provider.filesFind
  ({
    filePath : submodulesPath,
    recursive : 1,
    includingStem : 0,
    includingDirs : 1,
    includingTerminals : 0
  });

  let jsdocOutPath = path.resolve( 'out/docs/Packages' );

  modules.forEach( ( record ) =>
  {
    let protoPath = path.join( record.absolute, 'proto' );
    if( !provider.isDir( protoPath ) )
    return;

    let result = jsToMarkDownSingle( protoPath );
    if( !result )
    return;

    let mdFileOutPath = path.join( jsdocOutPath, record.name + '.md' );

    provider.fileWrite( mdFileOutPath, result );
  })
}


jsToMarkDown();

})();