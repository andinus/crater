'use strict';

const round = Math.round;

// image width.
const imgW = 400;

// Gallery using bricks.js ////////////////////////////////////////////////////

const sizes = [
    { columns: 1, gutter: 30 },
    { mq: round((imgW * 2.2) + 40) + "px", columns: 2, gutter: 40 },
    { mq: round((imgW * 3.5) + 50) + "px", columns: 3, gutter: 50 },
    { mq: round((imgW * 4.5) + 50) + "px", columns: 4, gutter: 50 },
    { mq: round((imgW * 5.5) + 60) + "px", columns: 5, gutter: 60 },
];

const bricks = Bricks({
    container: '#gallery',
    packed: 'data-packed',
    sizes: sizes
});

bricks
    .on('pack',   () => console.log('ALL grid items packed.'))
    .on('update', () => console.log('NEW grid items packed.'))
    .on('resize', size => console.log(
        'The grid has be re-packed to accommodate a new BREAKPOINT.', size
    ));

document.addEventListener('DOMContentLoaded', event => {
    bricks.resize(true).pack(); // bind resize handler & initial pack
});

/**
 * packing should be done multiple times. Sometimes the div of
 * directories is not properly packed if packing is done only once.
 */
// Packing after loading images ////////////////////////////////////////////

const showLoadingError = (message) => {
    const loadError = document.getElementById("loading-error");
    const loadErrorText = document.getElementById("loading-error-text");
    const loadErrorDismiss = document.getElementById("loading-error-dismiss");
    loadError.style.display = "block";
    loadErrorText.innerHTML = message;

    loadErrorDismiss.addEventListener('click', function(){
        loadError.style.display = "none";
    });
}

const onImagesLoaded = (container, event) => {
    const images = container.getElementsByTagName("img");
    const progressBar = document.getElementById("loading-progress");

    // Keeps track of how many times we've packed the images.
    let packed = 0;
    const incrementPackedAndPack = () => {
        packed++;
        bricks.pack();
    };

    // failed keeps track of images that failed to load.
    let failed = 0;
    let remaining = images.length;

    if (images.length === 0) {
        showLoadingError("No images to display.");
        event(remaining, failed, progressBar);
    }

    for (let i = 0; i < images.length; i++) {
        if (images[i].complete)
            remaining--;
        else {
            // Add listeners to images that have to be loaded.
            images[i].addEventListener("load", function () {
                remaining--;
                progressBar.value = round(
                    ((images.length - remaining) / images.length) * 100
                );

                // pack multiple times for better experience. This way
                // the initial pictures are properly visible to the
                // user while the other load. It's very cheap to pack
                // lots of elements too using bricks.js so it's not an
                // issue.
                //
                // There is no point in specifying such large ranges
                // as this runs in a single thread to for sure we'll
                // hit the range.
                if (5 < progressBar.value && progressBar.value < 20)
                    if (packed < 2)
                        incrementPackedAndPack();

                if (30 < progressBar.value && progressBar.value < 50)
                    if (packed < 4)
                        incrementPackedAndPack();

                if (80 < progressBar.value && progressBar.value < 95)
                    if (packed < 5)
                        incrementPackedAndPack();

                if (remaining === failed)
                    event(remaining, failed, progressBar);
            });

            // If loading fails then we increment failed, an error
            // will be shown later.
            images[i].addEventListener("error", function () {
                failed++;
                if (remaining === failed)
                    event(remaining, failed, progressBar);
            });

        }
        if (remaining == failed)
            event(remaining, failed, progressBar);
    }
};

const gallery = document.getElementById("gallery");
const imagesLoaded = (remaining, failed, progressBar) => {
    bricks.pack(); // packing images

    progressBar.value = 100;
    document.getElementById("loading").style.display = "none";

    // Show error on failure.
    if (failed !== 0) {
        const t = failed === 1 ? "image" : "images";
        showLoadingError(`${failed} ${t} failed to load.`);
    }
};

onImagesLoaded(gallery, imagesLoaded);
