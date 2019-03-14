( function _Manuals_Index_ss_() {

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

  _.assert( provider.isDir( outPath ), 'Out path:', outPath, 'is missing. Please run "will .build generate" to build documentation.' );
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

/* */

indexGenerate();

})();