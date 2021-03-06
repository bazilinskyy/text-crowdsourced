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
    mapping = pd.read_csv(te.common.get_configs('mapping'))

    def __init__(self):
        pass

    def create_stimuli(self):
        """
        Output correlation matrix.

        Args:
            df (dataframe): mapping dataframe.
            columns_drop (list): columns dataframes in to ignore.
            save_file (bool, optional): flag for saving an html file with plot.
        """
        # load mapping
        df = pd.read_csv(te.common.get_configs('mapping'))
        # load image with eHMI
        for index, row in df.iterrows():
            logger.info('Creating stimulus for message {}.', row['text'])
            # skip nan
            if te.common.is_nan(row['text']):
                logger.error('nan value detected.')
                continue
            try:
                overlay = Image.open(os.path.join(te.settings.root_dir,
                                                  'textehmi',
                                                  'stimuli',
                                                  'base',
                                                  str(int(row['id']))
                                                  + '.png'))
            except FileNotFoundError:
                logger.error('Base file for stimulus {} not found.', row['id'])
                # skip to next stimulus
                continue
            # convert to RGBA
            overlay = overlay.convert('RGBA')
            # resize
            overlay = overlay.resize([int(0.5 * s) for s in overlay.size],
                                     Image.ANTIALIAS)
            # load base image
            background = Image.open(os.path.join(te.settings.root_dir,
                                                 'textehmi',
                                                 'stimuli',
                                                 'bg.jpg'))
            # convert to RGBA
            background = background.convert('RGBA')
            # choose coordinates of eHMI on car
            if row['rows'] == 1:
                coords = (410, 375)
            elif row['rows'] == 2:
                coords = (410, 350)
            elif row['rows'] == 3:
                coords = (410, 325)
            elif row['rows'] == 4:
                coords = (410, 300)
            elif row['rows'] == 5:
                coords = (410, 275)
            else:
                logger.error('Unkown value of {} rows for stimulus {}.',
                             row['rows'],
                             row['id'])
            # overlay
            background.paste(overlay, coords, overlay)
            # disable transparency for jpg
            background = background.convert('RGB')
            # save as new file
            background.save(os.path.join(te.common.get_configs('path_stimuli'),
                                         'image_' + str(int(row['id'])) +
                                         '.jpg'))
