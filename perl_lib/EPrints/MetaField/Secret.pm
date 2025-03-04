######################################################################
#
# EPrints::MetaField::Secret;
#
######################################################################
#
#
######################################################################

=pod

=head1 NAME

B<EPrints::MetaField::Secret> - no description

=head1 DESCRIPTION

not done

=over 4

=cut

package EPrints::MetaField::Secret;

use strict;
use warnings;

BEGIN
{
	our( @ISA );
	
	@ISA = qw( EPrints::MetaField::Id );
}

use EPrints::MetaField::Id;

sub get_property_defaults
{
	my( $self ) = @_;

	my %defaults = $self->SUPER::get_property_defaults;
	$defaults{repeat_secret} = $EPrints::MetaField::FROM_CONFIG;
	$defaults{text_index} = 0;
	$defaults{sql_index} = 0;

	return %defaults;
}

sub get_sql_index
{
	my( $self ) = @_;

	return ();
}

sub render_value
{
	my( $self, $session, $value, $alllangs, $nolink ) = @_;

	if( defined $self->{render_value} )
	{
		return $self->call_property( "render_value",
			$session, 
			$self, 
			$value, 
			$alllangs, 
			$nolink );
	}

	# this won't handle anyone doing anything clever like
	# having multiple flags on a secret
	# field. If they do, we'll use a more default render
	# method.

	if( $self->get_property( 'multiple' ) )
	{
		return $self->SUPER::render_value( $session, $value, $alllangs, $nolink );
	}

	return $self->render_single_value( $session, $value, $nolink );
}

sub render_single_value
{
	my( $self, $session, $value ) = @_;

	return $session->html_phrase( 'lib/metafield/secret:show_value' );
}

sub get_basic_input_elements
{
	my( $self, $session, $value, $basename, $staff, $obj, $one_field_component ) = @_;

	my $maxlength = $self->get_property( "maxlength" );
	my $size = $self->{input_cols};
	my $password = $session->render_noenter_input_field(
		class => "ep_form_text",
		type => "password",
		name => $basename,
		id => $basename,
		size => $size,
		maxlength => $maxlength,
		'aria-labelledby' => $self->get_labelledby( $basename ),
		'aria-describedby' => $self->get_describedby( $basename, $one_field_component ) );

	if( !$self->get_property( "repeat_secret" ) )
	{
		return [ [ { el=>$password } ] ];
	}

	my $confirm = $session->render_noenter_input_field(
		class => "ep_form_text",
		type => "password",
		name => $basename."_confirm",
		id => $basename."_confirm",
		size => $size,
		maxlength => $maxlength,
		'aria-labelledby' => $self->get_labelledby( $basename ),
                'aria-describedby' => $self->get_describedby( $basename, $one_field_component ) );

	my $label1 = $session->make_element( "div", style=>"margin-right: 4px;" );
	$label1->appendChild( $session->html_phrase(
		$self->{dataset}->confid."_fieldname_".$self->get_name
	) );
	$label1->appendChild( $session->make_text( ":" ) );
	my $label2 = $session->make_element( "div", style=>"margin-right: 4px;" );
	$label2->appendChild( $session->html_phrase(
		$self->{dataset}->confid."_fieldname_".$self->get_name."_confirm"
	) );
	$label2->appendChild( $session->make_text( ":" ) );
	
	return [
		[ { el=>$label1 }, { el=>$password } ],
		[ { el=>$label2 }, { el=>$confirm } ]
	];
}

sub is_browsable
{
	return( 0 );
}


sub from_search_form
{
	my( $self, $session, $prefix ) = @_;

	$session->get_repository->log( "Attempt to search a \"secret\" type field." );

	return;
}

sub get_search_group { return 'secret'; }  #!! can't really search secret

# REALLY don't index passwords!
sub get_index_codes
{
	my( $self, $session, $value ) = @_;

	return( [], [], [] );
}

sub validate
{
	my( $self, $session, $value, $object ) = @_;

	my @probs = $self->SUPER::validate( $session, $value, $object );

	if( $self->get_property( "repeat_secret" ) )
	{
		my $basename = $self->get_name;

		my $password = $session->param( $basename );
		my $confirm = $session->param( $basename."_confirm" );

		if( !length($password) || $password ne $confirm )
		{
			push @probs, $session->html_phrase( "validate:secret_mismatch" );
		}
	}

	return @probs;
}

sub to_sax
{
	my( $self, $value, %opts );

	return if !$opts{show_secrets};

	$self->SUPER::to_sax( $value, %opts );
}

######################################################################

######################################################################
1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2022 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

