( function _StaticServer_ss_() {

'use strict';


if( typeof module !== 'undefined' )
{
  let _ = require( 'wFiles' );
}

let _ = _global_.wTools;
let path = _.path;
let provider = _.fileProvider;

/*  */


function indexGenerate()
{
  let outPath = path.resolve( 'out' );
  let mdPath = path.resolve( 'out/docs' );
  let mdIndexOut = path.join( mdPath, '_homepage.md' );

  _.assert( provider.isDir( mdPath ) );

  let dirs = provider.filesFind
  ({
    filePath : mdPath,
    recursive : 1,
    includingTerminals : 0,
    includingDirs : 1,
    includingStem : 0
  })

  let index = '# <center>Documentation</center>';

  dirs.forEach( ( dir ) =>
  {
    let files = provider.filesFind
    ({
      filePath : dir.absolute,
      recursive : 2,
      includingTerminals : 1,
      includingDirs : 1,
      includingStem : 0,
      filter : { ends : 'md' }
    })

    let readmePath = path.join( dir.absolute, 'README.md' );

    if( provider.fileExists( readmePath ) )
    {
      let p = path.join( '/', dir.relative, 'README.md' );
      index += `\n### ${dir.name}\n`
      index += `  * [${dir.name}](${path.undot( p )})\n`
    }
    else
    {
      index += `\n### ${dir.name}\n`

      files.forEach( ( record ) =>
      {
        let p = path.join( '/',dir.relative, record.relative );
        index += `  * [${record.name}](${ path.undot( p )})\n`
      })
    }
  })

  provider.fileWrite( mdIndexOut, index );
}

//

function serverStart()
{
  let express = require('express');
  let app = express();

  let outPath = path.nativize( path.resolve( 'out' ) );

  app.use( express.static( outPath ) );
  app.listen( 3000 );
  console.log('Listening at http://localhost:3000');
}

/* */

indexGenerate();
serverStart();

})();