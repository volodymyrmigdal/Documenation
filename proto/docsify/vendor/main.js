window.$docsify =
{
    name: 'Documentation',
    // repo: 'https://github.com/Wandalen/Documenation',
    basePath: '/docs',
    homepage : 'ReferenceIndex.md',
    loadSidebar : false,
    auto2top : true,
    markdown:
    {
      renderer:
      {
        link: rendererOnLink
      }
    }
}

window.onscroll = () =>
{
    let scrollToTop = document.getElementById( 'scrollToTop' );
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20)
    scrollToTop.style.display = 'block';
    else
    scrollToTop.style.display = 'none';
}

/* */

function rendererOnLink( href, title, text )
{
    if( strBegins( href, '/' ) )
    return this.origin.link( href,title,text );

    if( strBegins( href, '#' ) )
    {
    let currentPath = document.location.href.replace( document.location.origin + '/#/','' );
    if( strHas( currentPath, '?' ) )
    currentPath = currentPath.substring( 0,currentPath.indexOf( '?' ) );
    let id = href.substring( 1 );
    href = currentPath + '?id=' + id;
    }
    else if( /\.md$/.test( href ) )
    {
    let currentPath = document.location.href.replace( document.location.origin + '/#','' );
    let currentDir = currentPath.substring( 1,currentPath.lastIndexOf( '/' ) );
    href = currentDir + '/' + href;
    }

    return `<a href="/#/${href}" title="${title}">${text}</a>`
}

//

function strBegins( src, begin )
{
    return src.lastIndexOf( begin, 0 ) === 0;
}

//

function strHas( src, has )
{
    return src.indexOf( has ) != -1;
}

//

function scrollToTop()
{
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}