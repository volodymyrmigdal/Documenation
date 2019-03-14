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

serverStart();

})();