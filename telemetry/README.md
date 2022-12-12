# Telemetry
An orb that enables Team CPPE to send telemetry about our products usage to the
telemetry endpoint.

Team CPPE collect telemetry about the usage of our products to ensure that we
are delivering appropriate value to the teams that we support. The telemetry we
collect is designed to give us an idea of how frequently our products are being
used, how many teams have adopted them, whether they are being used in the
manner we envisaged, how reliable they are, etc. 
Sensitive data is masked before
submission, so we never see any sensitive details that you wouldn't want us to.

## Usage
The orb is designed to be embedded within another orb, and follows the decorator
pattern in order to wrap the other jobs or commands in the orb. See the examples
folder for more detailed usage examples.
