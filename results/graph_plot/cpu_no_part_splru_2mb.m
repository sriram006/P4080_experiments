function [fitresult, gof] = cpu_no_part_splru_2mb(number_of_active_cores, execution_time_in_cycles)
%CREATEFIT(NUMBER_OF_ACTIVE_CORES,EXECUTION_TIME_IN_CYCLES)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : number_of_active_cores
%      Y Output: execution_time_in_cycles
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 18-Jul-2016 18:19:26


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( number_of_active_cores, execution_time_in_cycles );

% Set up fittype and options.
ft = fittype( 'poly6' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [1.23676080755676 -0.0663822034989268 -0.251611660215572 -0.26456999919241];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult,'k','predobs', 0.95 );
hold on
plot(xData, yData,'k square', 'MarkerFaceColor',[0,0,0]);
disp('done')
legend( h, 'data', 'fitted curve', 'Lower and Upper bounds based on PI', 'Location', 'NorthWest' );
% Label axes
xlabel( 'number of interfering cores' );
ylabel( 'normalized number of cpc cache hits' );
grid off


