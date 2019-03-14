( function _js2md_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( 'wFiles' );
  _.include( 'wExternalFundamentals' );
  var jsdoc2md = require( 'jsdoc-to-markdown' );
  var state = require( 'dmd/lib/state.js' );
}

let _ = _global_.wTools;
let path = _.path;
let provider = _.fileProvider;

let jsDoc2Md = _global_.jsdoc2md = Object.create( null );
jsDoc2Md.currentFile = null;
jsDoc2Md.searchIndex = Object.create( null );

/*  */

function jsToMarkDownSingle( srcPath )
{
  let jsdocConf = path.join( __dirname, 'jsdoc.json' );

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

  let partials = [ 'sig-link-parent.hbs', 'docs.hbs', 'header.hbs', 'hr-line.hbs', 'sig-name.hbs' ];
  let partialsPath = path.s.join( __dirname, 'partials', partials );

  let helperPath = path.s.join( __dirname, 'helpers/helper.ss' );

  let result = jsdoc2md.renderSync
  ({
    files : nativizedFiles,
    configure : nativizedConf,
    partial : path.s.nativize( partialsPath ),
    helper : path.nativize( helperPath ),
    'member-index-format' : 'list'
  });

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

  /* Reference generation: one md file per module  */

  let jsdocOutPath = path.resolve( 'out/docs/Reference' );
  let searchFilePath = path.resolve( 'out/searchIndex.json' );

  modules.forEach( ( record ) =>
  {
    let protoPath = path.join( record.absolute, 'proto' );
    if( !provider.isDir( protoPath ) )
    return;

    jsDoc2Md.currentFile = record.name;

    let result = jsToMarkDownSingle( protoPath );

    jsDoc2Md.currentFile = null;

    if( !result )
    return;

    let mdFileOutPath = path.join( jsdocOutPath, record.name + '.md' );

    provider.fileWrite( mdFileOutPath, result );

  })

  provider.fileWrite({ filePath : searchFilePath, data : jsDoc2Md.searchIndex, encoding : 'json.min' });

  /* Modules index generation */

  let modulesPaths = path.s.join( _.select( modules, '*/absolute' ), 'proto' );
  let jsdocConf = path.join( __dirname, 'jsdoc.json' );

  let nativizedConf = path.nativize( jsdocConf );

  let partials = [ 'reference-index.hbs', 'module-index-dl.hbs', 'global-index-dl.hbs' ];
  let partialsPath = path.s.join( __dirname, 'partials/reference-index-template', partials );
  let helperPath = path.s.join( __dirname, 'helpers/helper.ss' );

  /* Getting jsdoc data from modules */

  var files = provider.filesFind
  ({
    filePath : modulesPaths,
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

  let nativizedFiles = path.s.nativize( files );

  state.templateDataOriginal = jsdoc2md.getTemplateDataSync
  ({
    files : nativizedFiles,
    configure : nativizedConf,
  });

  /* Adding more info to use later in template */

  state.templateDataOriginal.forEach( ( data ) =>
  {
    if( data.meta )
    {
      let normalizedPath = path.normalize( data.meta.path );
      let isolated = _.strIsolateRightOrAll( normalizedPath, '/proto' )
      data.meta.moduleName = path.name( isolated[ 0 ] );
    }
  })

  let result = jsdoc2md.renderSync
  ({
    data : state.templateDataOriginal,
    partial : path.s.nativize( partialsPath ),
    helper : path.nativize( helperPath ),
    template : '{{>reference-index}}'
  });

  let mdReferenceIndexOutPath = path.resolve( 'out/docs/ReferenceIndex.md' );
  provider.fileWrite( mdReferenceIndexOutPath, result );

}

//

jsToMarkDown();

})();