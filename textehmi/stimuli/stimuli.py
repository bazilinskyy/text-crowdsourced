# by Pavlo Bazilinskyy <pavlo.bazilinskyy@gmail.com>
try:
    from PIL import Image
except ImportError:
    import Image
import pandas as pd
import os

import textehmi as te

logger = te.CustomLogger(__name__)  # use custom logger


class Stimuli:
    # pandas dataframe with mapping
    mapping = pd.read_csv(te.common.get_configs('mapping_stimuli'))

    def __init__(self):
        print('stimuli class here')

    def create_stimuli(self):
        """
        Output correlation matrix.

        Args:
            df (dataframe): mapping dataframe.
            columns_drop (list): columns dataframes in to ignore.
            save_file (bool, optional): flag for saving an html file with plot.
        """
        logger.info('Creating stimuli.')
        # load mapping
        df = pd.read_csv(te.common.get_configs('mapping_stimuli'))
        # load base image
        background = Image.open(os.path.join(te.settings.root_dir,
                                             'textehmi',
                                             'stimuli',
                                             'bg.png'))
        # convert to RGBA
        background = background.convert('RGBA')
        # load image with eHMI
        for index, row in df.iterrows():
            try:
                overlay = Image.open(os.path.join(te.settings.root_dir,
                                                  'textehmi',
                                                  'stimuli',
                                                  'base',
                                                  str(row['id']) + '.png'))
            except FileNotFoundError:
                logger.error('Base file for stimulus {} not found.', row['id'])
                # skip to next stimulus
                continue
            # convert to RGBA
            overlay = overlay.convert('RGBA')
            # resize
            overlay = overlay.resize([int(0.5 * s) for s in overlay.size],
                                     Image.ANTIALIAS)
            # overlay
            background.paste(overlay, (420, 375), overlay)
            # save as new file
            background.save(os.path.join(te.common.get_configs('path_stimuli'),
                                         str(row['id']) + '_overlaid' + '.png'),
                            'PNG')
