'use strict';
/* import Bricks from '/bricks.js'; */

// mq      - the minimum viewport width (String CSS unit: em, px, rem)
// columns - the number of vertical columns
// gutter  - the space (in px) between the columns and grid items

// image width.
const imgW = 384;

const sizes = [
    { columns: 1, gutter: 30 },
    { mq: ((imgW * 2.5) + 40) + "px", columns: 2, gutter: 40 },
    // { mq: '768px', columns: 2, gutter: 25 },
    // { mq: '1280px', columns: 3, gutter: 50 }
];

const instance = Bricks({
    container: '.gallery',
    packed: 'data-packed',
    sizes: sizes
});

instance
    .on('pack',   () => console.log('ALL grid items packed.'))
    .on('update', () => console.log('NEW grid items packed.'))
    .on('resize', size => console.log('The grid has be re-packed to accommodate a new BREAKPOINT.', size));

// start it up, when the DOM is ready. note that if images are in the
// grid, you may need to wait for document.readyState === 'complete'.

document.addEventListener('DOMContentLoaded', eve => {
    document.addEventListener('readystatechange', event => {
        if (event.target.readyState === 'complete') {
            instance
                .resize(true)     // bind resize handler
                .pack()           // pack initial items
        }
    })
})
