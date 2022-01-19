# by Pavlo Bazilinskyy <pavlo.bazilinskyy@gmail.com>
# import matplotlib.pyplot as plt
# import matplotlib._pylab_helpers

import textehmi as te

te.logs(show_level='debug', show_color=True)
logger = te.CustomLogger(__name__)  # use custom logger

# Const
SAVE_P = True  # save pickle files with data
LOAD_P = False  # load pickle files with data
SAVE_CSV = True  # load csv files with data
CREATE_STIMULI = False  # create stimuli based on base image
CLEAN_DATA = True  # clean Appen data
REJECT_CHEATERS = False  # reject cheaters on appen

if __name__ == '__main__':
    # create stimuli
    if CREATE_STIMULI:
        stimuli = te.stimuli.Stimuli()
        stimuli.create_stimuli()
    # create object for working with appen data
    file_appen = te.common.get_configs('file_appen')
    appen = te.analysis.Appen(file_data=file_appen,
                              save_p=SAVE_P,
                              load_p=LOAD_P,
                              save_csv=SAVE_CSV)
    # read appen data
    appen_data = appen.read_data(clean_data=CLEAN_DATA)
    # flag and reject cheaters
    if REJECT_CHEATERS:
        qa = te.analysis.QA(file_cheaters=te.common.get_configs('file_cheaters'),  # noqa: E501
                            job_id=te.common.get_configs('appen_job'))
        qa.flag_users()
        qa.reject_users()
