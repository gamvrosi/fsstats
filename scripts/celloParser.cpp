#include <bitset>
#include <iostream>
#include <iomanip>
#include <cstdio>
#include <cmath>
#include <string>
using namespace std;

#include <DataSeries/DataSeriesModule.hpp>
#include <DataSeries/ExtentField.hpp>
#include <DataSeries/RowAnalysisModule.hpp>
#include <DataSeries/TypeIndexModule.hpp>

double st_offset = 0.0;

/* RowAnalysisModule handles the details of getting each extent
   and iterating over the rows using the ExtentSeries series. */
class CelloAnalysis : public RowAnalysisModule {
public:
	/*  Our constructor takes a DataSeriesModule from which to get
        Extents and passes it on to the base class constructor.
        Then, we use the inherited ExtentSeries called series to
        initialize the Fields.  An ExtentSeries is an iterator
        over the records of Extents.  Fields are connected to
        a particular ExtentSeries and provide access to the
        values of each record as the ExtentSeries points to it. */
	CelloAnalysis(DataSeriesModule& source)
		: RowAnalysisModule(source),
		  enter(series,"enter_driver"),
		  leave(series,"return_to_driver"),
		  filter(series,"is_suspect"),
		  bytes(series,"bytes"),
		  offset(series,"disk_offset"),
		  devmajor(series,"device_major"),
		  devminor(series,"device_minor"),
		  devctrl(series,"device_controller"),
		  devdisk(series,"device_disk"),
		  devpart(series,"device_partition"),
		  drvtype(series,"driver_type"),
		  qlength(series,"queue_length"),
		  lvnum(series,"logical_volume_number", Field::flag_nullable),
		  isread(series,"is_read"),
		  fcache(series,"flag_cache"),
		  fmerge(series,"flag_merged") {
		count = clean_count = 0;
		enterT = leaveT = 0;
		enterT_prev = -1;
		searchFirst = 1;
		start = end = 0;
		unit = pow(2,32);
		duration = 0;
		response = 0;
	}
	// Add more once the code is debugged

	/* There are a couple of functions that we need to override.
        The first is processRow.  This function will be called
        by RowAnalysisModule once for every row in the Extents
        being processed. */
	virtual void processRow() {
		++count;

		enterT = enter.val() / unit;
		leaveT = leave.val() / unit;
		response = leaveT - enterT;


		if (!((enterT == 0 && (leaveT >= 2147.4836468 && leaveT <= 2147.4836472)) || filter.val())) {
			++clean_count;
			if (!searchFirst && (enterT - enterT_prev < -10 || enterT - start > 3600)) {
				duration += end-start;
				start = enterT;

				/*std::cout << "Duration change here:\n" << fixed << setprecision(6)
					<< enterT << "\t" << leaveT << "\t" << setbase(10)
					<< bytes.val() << "\t" << setbase(10) << offset.val()
					<< "\t" << "c" << bitset<8>(devminor.val()).to_ulong()
					<< "t" << bitset<8>(devctrl.val()).to_ulong() << "d"
					<< bitset<8>(devdisk.val()).to_ulong() << std::endl;*/
			}
			if (searchFirst) {
				start = enterT;
				duration = 0;
				searchFirst = 0;

				/*std::cout << "First Request:\n" << fixed << setprecision(6)
					<< enterT << "\t" << leaveT << "\t" << setbase(10)
					<< bytes.val() << "\t" << setbase(10) << offset.val()
					<< "\t" << "c" << bitset<8>(devminor.val()).to_ulong()
					<< "t" << bitset<8>(devctrl.val()).to_ulong() << "d"
					<< bitset<8>(devdisk.val()).to_ulong() << std::endl;*/
			}

			enterT_adj = st_offset + (enterT - start);
			leaveT_adj = st_offset + (leaveT - start);
			/* Print interarrival times, responce times, disk */
                        std::cout << fixed << setprecision(6) << enterT_adj << "\t" << leaveT_adj << "\t"
				<< response << "\t" << isread.val() << "\t" << setbase(10) << bytes.val()
				<< "\t" << setbase(10) << offset.val() << "\t" << "c"
				<< bitset<8>(devminor.val()).to_ulong() << "t"
				<< bitset<8>(devctrl.val()).to_ulong() << "d"
				<< bitset<8>(devdisk.val()).to_ulong() << "\t" << qlength.val() << std::endl;

			end = leaveT;
			enterT_prev = enterT;
		}
	}

	/* The second function to override is printResult.  This function will be
        called at the end of the processing.  Even though we are calling it
        directly from main, it is a good idea to implement  so
        that some more complex things will work correctly.  See
        running_multiple_modules.cpp */
	virtual void printResult() {
		/*std::cout << "Total count: " << count << "/ Clean count: " << clean_count << std::endl;*/
		//std::cout << "Last Request:\n" << fixed << enterT << "\t" << leaveT << "\t" << std::endl;

		//duration += end - start;
		//std::cout << "Hour Summary:" << std::endl;
		//std::cout << "Duration: " << duration << std::endl;
		//std::cout << "Clean/Total requests: " << clean_count << " / " << count << "\n" << std::endl;
	}
private:
	/* The fields we will access in each row. In the real implementation the field
	   names are constructor arguments so that the module can operate on any fields
	   of the appropriate type. */
	Int64Field enter;
	Int64Field leave;
	BoolField filter;
	Int32Field bytes;
	Int64Field offset;
	ByteField devmajor;
	ByteField devminor;
	ByteField devctrl;
	ByteField devdisk;
	ByteField devpart;
	Int32Field drvtype;
	Int32Field qlength;
	Int32Field lvnum;
	BoolField isread;
	BoolField fcache;
	BoolField fmerge;
	long count;
	long clean_count;
	double unit;

	/* Time adjustment variables */
	double start; // Start of current duration interval
	double end; // End of current duration interval
	double enterT; // Timestamp to be seen next (clean enter)
	double enterT_adj; // Timestamp to be seen next (clean enter)
	double enterT_prev; // Timestamp to be seen next (clean enter)
	double leaveT; // Timestamp to be seen next (clean leave)
	double leaveT_adj; // Timestamp to be seen next (clean leave)
	int hour; // Current hour
	int searchFirst; // Searching for the first 'correct' request
	int duration;
	double response;
};

/* Now, we're ready to actually run the analysis. */

int main(int argc, char *argv[]) {

	/*  The first thing to do is to specify which
        Extents are going to processed.  The TypeIndexModule
        class reads all the Extents of a single type
        from a group of files.  We construct one
        that processes Extents of the type "MyExtent"
        and load it up with the files passed on the
        command line. */
	TypeIndexModule source("Trace::BlockIO::HP-UX");

	// Use first argument as offset
	if (argc < 2) {
		std::cout << "Need offset!" << std::endl;
		return 1;
	}
	st_offset = atof(argv[1]);
	//std::cout << "Offset = " << offset << std::endl;

	// Add in all the files to the source module.
	for (int i=2; i<argc; ++i) {
		source.addSource(argv[i]);
	}

	CelloAnalysis analysis(source);

	// Read all extents, delete after processing.
	analysis.getAndDelete();

	analysis.printResult();
	return 0;
}

