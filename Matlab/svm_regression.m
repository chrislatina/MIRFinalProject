% =========================================================================
% This function use the svm as the model of regression
% =========================================================================
% @param train_data
% @param train_label
% @param test_data
% =========================================================================
% @retval estimated_result: values are between 0 and 1 which indicate the
% predicted year


function estimated_result = svm_regression(train_data, train_label, test_data)
    tic;model = svmtrain(train_label, train_data, ['-s 3 -t 2 -n ' num2str(0.5) ' -c ' num2str(1)]);toc;
    tic;estimated_result = svmpredict(test_label, test_data, model);
end