# by Pavlo Bazilinskyy <pavlo.bazilinskyy@gmail.com>
# import matplotlib.pyplot as plt
# import matplotlib._pylab_helpers

import textehmi as te

te.logs(show_level='info', show_color=True)
logger = te.CustomLogger(__name__)  # use custom logger

# Const
SAVE_P = True  # save pickle files with data
LOAD_P = False  # load pickle files with data
SAVE_CSV = True  # load csv files with data
CREATE_STIMULI = True  # create stimuli based on base image
ANALYSE = False  # conduct analysis
FILTER_DATA = True  # filter Appen and heroku data
CLEAN_DATA = True  # clean Appen data
REJECT_CHEATERS = True  # reject cheaters on Appen
UPDATE_MAPPING = True  # update mapping with keypress data
SHOW_OUTPUT = True  # should figures be plotted

file_mapping = 'mapping.p'  # file to save updated mapping

if __name__ == '__main__':
    # create sitmuli
    if CREATE_STIMULI:
        stimuli = te.stimuli.Stimuli()
        stimuli.create_stimuli()
    # conduct analysis
    if ANALYSE:
        # create object for working with heroku data
        files_heroku = te.common.get_configs('files_heroku')
        heroku = te.analysis.Heroku(files_data=files_heroku,
                                    save_p=SAVE_P,
                                    load_p=LOAD_P,
                                    save_csv=SAVE_CSV)
        # read heroku data
        heroku_data = heroku.read_data(filter_data=FILTER_DATA)
        # create object for working with appen data
        file_appen = te.common.get_configs('file_appen')
        appen = te.analysis.Appen(file_data=file_appen,
                                  save_p=SAVE_P,
                                  load_p=LOAD_P,
                                  save_csv=SAVE_CSV)
        # read appen data
        appen_data = appen.read_data(filter_data=FILTER_DATA,
                                     clean_data=CLEAN_DATA)
        # get keys in data files
        heroku_data_keys = heroku_data.keys()
        appen_data_keys = appen_data.keys()
        # flag and reject cheaters
        if REJECT_CHEATERS:
            qa = te.analysis.QA(file_cheaters=te.common.get_configs('file_cheaters'),  # noqa: E501
                                job_id=te.common.get_configs('appen_job'))
            qa.flag_users()
            qa.reject_users()
        # merge heroku and appen dataframes into one
        all_data = heroku_data.merge(appen_data,
                                     left_on='worker_code',
                                     right_on='worker_code')
        logger.info('Data from {} participants included in analysis.',
                    all_data.shape[0])
