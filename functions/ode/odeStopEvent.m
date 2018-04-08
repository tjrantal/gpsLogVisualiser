function [value,isterminal,direction] = odeStopEvent(t,y)
  value = y(5);        % Extract the current height.
  isterminal = 1;      % Stop the integration if height crosses zero.
  direction = -1;      % But only if the height is decreasing.