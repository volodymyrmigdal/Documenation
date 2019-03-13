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
  let referenceIndexPath = path.join( mdPath, 'ReferenceIndex.md' );

  let manualsPath = path.join( mdPath, 'Manuals' );
  let referencePath = path.join( mdPath, 'Reference' );

  _.assert( provider.isDir( manualsPath ) );
  _.assert( provider.isDir( referencePath ) );

  let referenceIndex = '# <center>Reference</center>';
  let manualsIndex = '# <center>Manuals</center>';

  /* reference index */

  // let files = provider.filesFind
  // ({
  //   filePath : referencePath,
  //   recursive : 2,
  //   includingTerminals : 1,
  //   includingDirs : 1,
  //   includingStem : 0,
  //   filter : { ends : 'md' }
  // })

  // files.forEach( ( record ) =>
  // {
  //   let p = path.join( '/Reference', record.relative );
  //   referenceIndex += `\n  * [${record.name}](${ path.undot( p )})`
  // })

  // provider.fileWrite( referenceIndexPath, referenceIndex );

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

    let readmePath = path.join( dir.absolute, 'README.md' );

    if( provider.fileExists( readmePath ) )
    {
      let p = path.join( '/Manuals', dir.relative, 'README.md' );
      manualsIndex += `\n### ${dir.name}\n`
      manualsIndex += `  * [README](${path.undot( p )})\n`
    }
    else
    {
      manualsIndex += `\n### ${dir.name}\n`

      files.forEach( ( record ) =>
      {
        let p = path.join( '/Manuals',dir.relative, record.relative );
        manualsIndex += `  * [${record.name}](${ path.undot( p )})\n`
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