The output of `run_analysis.R` is a single file called `tidy.txt` that contains the following fields:

| Field Name | Field Type | Field Description |
| :--------- | :--------- | :---------------- |
| subject | *character* | The ID of the participant in the study. |
| activity | *character* | The description of the activity the subject was performing. |
| feature | *character* | The description of a feature derived from measurements taken while the subject performed the activity.  These are complex features that are well documented in the original [UCI Machine Learning Repository page](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).  Only a subset of the original features were retained (those utilizing a mean or standard-deviation to summarize the measurements). |
| average | *numeric* | The average value of the feature while the subject performed the activity. |

*Each row is a unique combination of subject, activity and feature.*
