function model = svm_regression(y, x)
%     tic;model = svmtrain(y, x, ['-s 3 -t 2 -n ' num2str(0.5) ' -c ' num2str(1)]);toc;
    model = svmtrain(y, x, '-s 4');
end