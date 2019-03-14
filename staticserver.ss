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
  let manualsIndexPath = path.join( mdPath, 'ManualsIndex.md' );

  let manualsPath = path.join( mdPath, 'Manuals' );

  _.assert( provider.isDir( manualsPath ) );

  let manualsIndex = '# <center>Manuals</center>';
  let manualsLocalPath = '/Manuals';

  /* manuals index */

  let dirs = provider.filesFind
  ({
    filePath : manualsPath,
    recursive : 1,
    includingTerminals : 0,
    includingDirs : 1,
    includingStem : 0
  })

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

    let readmePath = path.join( dir.absolute, 'doc/README.md' );

    if( provider.fileExists( readmePath ) )
    {
      let localPath = path.join( manualsLocalPath, dir.relative, 'doc/README.md' );
      localPath = path.undot( localPath );

      manualsIndex += `\n### ${dir.name}\n`
      manualsIndex += `  * [${dir.name}/README](${localPath})\n`
    }
    else
    {
      manualsIndex += `\n### ${dir.name}\n`

      files.forEach( ( record ) =>
      {
        let localPath = path.join( manualsLocalPath,dir.relative, record.relative );
        localPath = path.undot( localPath );
        let title = _.strRemoveBegin( record.relative, './doc/' );
        title = path.withoutExt( title );

        manualsIndex += `  * [${title}](${localPath})\n`
      })
    }
  })

  provider.fileWrite( manualsIndexPath, manualsIndex );
}

//

function serverStart()
{
  let express = require('express');
  let app = express();

  let outPath = path.nativize( path.resolve( 'out' ) );
  let searchIndexPath = path.join( outPath, 'searchIndex.json' );

  let index = provider.fileRead({ filePath : searchIndexPath, encoding : 'json' });
  let cachedResults = Object.create( null );

  app.use( express.static( outPath ) );
  app.get( '/search', ( req, res ) =>
  {
    let result;
    let query = req.query.q;

    if( cachedResults[ query ] )
    {
      result = cachedResults[ query ];
    }
    else if( index[ query ] )
    {
      result =
      {
        results : [ index[ query ] ],
      }
    }
    else
    {
      let items = [];
      let maxItems = 10;

      var reg = new RegExp( query, 'i' );

      for( var k in index )
      {
        if( k.match( reg ) )
        {
          items.push( index[ k ] );
          if( items.length === maxItems )
          break;
        }
      }

      result =
      {
        results : items,
      }

      cachedResults[ query ] = result;
    }

    res.send( result );
  })

  app.listen( 3000 );
  console.log('Listening at http://localhost:3000');
}

/* */

indexGenerate();
serverStart();

})();