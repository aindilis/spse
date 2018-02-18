#!/usr/bin/perl -w

use KBS2::Client;

my $kbs2 = KBS2::Client->new();

foreach my $context (
		     # "Goal-Removal-Test",
		     "Org::FRDCSA::Verber::PSEx2::Verber",
		     "Revival",
		     "Org::FRDCSA::Verber::PSEx2::View2",
		     "Org::FRDCSA::Verber::PSEx2::Do",
		     "EtherBoard",
		     "IAHCL",
		     "Org::FRDCSA::PaperlessOffice::ScanningNewDocuments",
		     "Org::FRDCSA::SPSE2::Default",
		     "Org::FRDCSA::Task1::Do",
		     "Org::FRDCSA::Verber::PSEx2",
		     "Org::PICForm::Todo",
		     "SPSE2",
		     "Org::POSI::Members::JustinCoslor",
		     "Plan-BecomeADebianDeveloper",
		     "SPSE2::Presentation2",
		     "SPSE2::Servers",
		     "Org::POSI::Members::KateJelinski",
		     "SPSE2-Demonstration",
		     "SPSE2::Justin",
		     "POSIC",
		     "SPSE2::Presentation",
		     "SPSE2::Presentations::JSRapidResponse",
		     "Org::FRDCSA::SPSE2::Domains::New",
		     "Org::POSI::Members::ChrisLampkin",
		     "Test"
		    ) {
  my $res = $kbs2->Send
    (
     QueryAgent => 1,
     Assert => [["frdcsa-context-type", "SPSE"]],
     InputType => "Interlingua",
     Context => $context,
     Flags => {
	       AssertWithoutCheckingConsistency => 1,
	      },
    );
}
