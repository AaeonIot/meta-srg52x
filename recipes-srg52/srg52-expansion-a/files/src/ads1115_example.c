/*
 * SRG-3352x Expansion Mode A
 * ADC example code
 * 
 * the code modify from
 * 	https://github.com/giobauermeister/ads1115-linux-rpi
 * 
 */
#include <gpiod.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <getopt.h>

#include "ads1115.h"

#define VERSION     		"1.1.0"

#define	CONSUMER			"EXADC_Consumer"
#define ADC_SET_PIN_MAX			4

static char *gpio0 = "gpiochip0";
static char *gpio2 = "gpiochip2";
static int addr_adc = 0x48;
static char *i2cbus = "/dev/i2c-0";
static int pinnums[ADC_SET_PIN_MAX] = { 15, 16, 17, 8 };
static int pinport[ADC_SET_PIN_MAX] = { 2, 2, 2, 0 };

#define VOLTAGE_MODE 		(0)
#define CURRENT_MODE		(1)
#define INVALID_MODE		(-1)
#define CHANNEL_MAX		4
#define DIFFGROUP_MAX		2

static int chmode[CHANNEL_MAX] = {INVALID_MODE, INVALID_MODE, INVALID_MODE, INVALID_MODE};
static int groupmode[DIFFGROUP_MAX] = {INVALID_MODE, INVALID_MODE};

static void sTitle(void) {
	fprintf(stderr, "SRG-3352x Ex-A ADC tool, " VERSION "\n");
}

static void usage(void) {
	sTitle();
	fprintf(stderr, "\n  options:\n");
	fprintf(stderr, "\t-h, --help         -- show this message\n");
	fprintf(stderr, "\t-c, --channel=[value] -- channel index, supprt 0~3\n");
	fprintf(stderr, "\t-m, --mode=[value] -- voltage or current mode, support 0~1\n");
	fprintf(stderr, "\t                                 0 for voltage\n");
	fprintf(stderr, "\t                                 1 for current\n");
	fprintf(stderr, "\t-a, --all-channel-mode, 4 parameters for modes of 4 channels\n");
	fprintf(stderr, "\t                                 0 for voltage\n");
	fprintf(stderr, "\t                                 1 for current\n");
	fprintf(stderr, "\t                                 -1 for ignore\n");
	fprintf(stderr, "\t-g, --group=[value] -- difference group idx, support 0~1\n");
	fprintf(stderr, "\t-d, --all-difference-group, 2 parameters for modes of 2 difference group\n");
	fprintf(stderr, "\t                                 0 for voltage\n");
	fprintf(stderr, "\t                                 1 for current\n");
	fprintf(stderr, "\t                                 -1 for ignore\n");
	fprintf(stderr, "Example:\n");
	fprintf(stderr, "\trd_exadc -c 0 -m 0, read channel 0 in voltage\n");
	fprintf(stderr, "\trd_exadc -c 2 -m 1, read channel 2 in current\n");
	fprintf(stderr, "\trd_exadc -a 0 1 -1 0, represent channel 0~3 in voltage, current, ignore, volatge, read channel 0,1,3 only\n");
	fprintf(stderr, "\trd_exadc -g 0 -m 0, read difference voltage of group 0 (channel 0 and 1)\n");
	fprintf(stderr, "\trd_exadc -g 0 -m 0, read difference current of group 1 (channel 2 and 3)\n");
	fprintf(stderr, "\trd_exadc -d 0 1, represent group 0 in voltage difference, group 1 in current difference\n");
	fprintf(stderr, "\n");
}

static const char *short_options = "hc:m:a:g:d:";
static const struct option long_options[] = {
	{"help", no_argument, NULL, 'h'},
	{"channel", required_argument, NULL, 'c'},
	{"mode", required_argument, NULL, 'm'},
	{"all-channel-mode", required_argument, NULL, 'a'},
	{"group", required_argument, NULL, 'g'},
	{"all-difference-group", required_argument, NULL, 'd'}
};

static int preprocess_cmd_option(int argc, char *argv[]) {
	int ch = -1;
	int mode = INVALID_MODE;
	int group = -1;
	int result = 0;
	int optCount = 0;
	int i;
	bool loop = true;
	bool diffmode = false;

	while (loop) {
		int c = -1;
		int opt_idx = 0;
		c = getopt_long(argc, argv, short_options, long_options, &opt_idx);
		optCount++;
		if (c == -1) {
			break;
		}
		switch(c) {
			case 'h':
				result = -1;
				break;
			case 'c':
				ch = atoi(optarg);
				//printf("ch: %d\n", ch);
				if((ch < 0) || (ch >= CHANNEL_MAX))
				{
					fprintf(stderr, "missed/incorrect argument. '-c/--channel'\n");
					return -1;
				}
				break;
			case 'm':
				mode = atoi(optarg);
				//printf("mode: %d\n", mode);
				if((mode != VOLTAGE_MODE) && (mode != CURRENT_MODE))
				{
					fprintf(stderr, "missed/incorrect argument. '-m/--mode'\n");
					return -1;
				}
				break;
			case 'a':
				for(i=0; i<CHANNEL_MAX; i++)
				{
					chmode[i] = atoi(argv[optind - 1 + i]);
					//printf("chmode[%d]: %d\n", i, chmode[i]);
				}
				loop = false;
				break;
			case 'g':
				group = atoi(optarg);
				//printf("group: %d\n", group);
				if((group < 0) || (group >= DIFFGROUP_MAX))
				{
					fprintf(stderr, "missed/incorrect argument. '-d/--diff'\n");
					return -1;
				}
				break;
			case 'd':
				for(i=0; i<DIFFGROUP_MAX; i++)
				{
					groupmode[i] = atoi(argv[optind - 1 + i]);
					//printf("groupmode[%d]: %d\n", i, groupmode[i]);
				}
				loop = false;
				break;
		}
	}

	if( (group != -1) && (mode != INVALID_MODE) )
	{
		groupmode[group] = mode;
	}

	for(i=0; i<DIFFGROUP_MAX; i++)
	{
		if(groupmode[i] != INVALID_MODE)
		{
			chmode[i*DIFFGROUP_MAX] = groupmode[i];
			chmode[i*DIFFGROUP_MAX+1] = groupmode[i];
			diffmode = true;
		}
	}
	
	if(!diffmode)
	{
		if( (ch != -1) && (mode != INVALID_MODE) )
		{
			chmode[ch] = mode;
		}
	}
	
	for(i=0; i<DIFFGROUP_MAX; i++)
	{
		if(groupmode[i] != INVALID_MODE)
		{
			printf("groupmode[]: %d %d\n", groupmode[0], groupmode[1]);
			break;
		}
	}
	for(i=0; i<CHANNEL_MAX; i++)
	{
		if(chmode[i] != INVALID_MODE)
		{
			printf("chmode[]: %d %d %d %d\n", chmode[0], chmode[1], chmode[2], chmode[3]);
			return 0;
		}
	}
				
	return -1;
}

int main(int argc, char **argv)
{
	int cmd_opt = 0;
	//int mode;
	bool diffmode = false;

	int i, ret;
	struct gpiod_chip *chip0;
	struct gpiod_chip *chip2;
	struct gpiod_line *line[4];

	cmd_opt = preprocess_cmd_option(argc, argv);
	if (cmd_opt != 0) {
		usage();
		exit(0);
	}

	if(openI2CBus(i2cbus) == -1)
	{
		return EXIT_FAILURE;
	}
	setI2CSlave(addr_adc);

	chip0 = gpiod_chip_open_by_name(gpio0);
	if (!chip0) {
		perror("Open gpiochip0 failed\n");
		ret = EXIT_FAILURE;
		goto end;
	}
	chip2 = gpiod_chip_open_by_name(gpio2);
	if (!chip2) {
		perror("Open gpiochip2 failed\n");
		ret = EXIT_FAILURE;
		goto end;
	}

	// set ADC_SET0-3 to low for voltage mode, high for current mode
	for(i = 0; i < ADC_SET_PIN_MAX; i++) {
		if(pinport[i] == 0)
		{
			line[i] = gpiod_chip_get_line(chip0, pinnums[i]);
			//printf("[%d]: pinport[i]=%d, pinnums[i]=%d, chip0, line[i]=0x%x\n", i, pinport[i], pinnums[i], line[i]);
		}
		else
		{
			line[i] = gpiod_chip_get_line(chip2, pinnums[i]);
			//printf("[%d]: pinport[i]=%d, pinnums[i]=%d, chip2, line[i]=0x%x\n", i, pinport[i], pinnums[i], line[i]);
		}
		if (!line[i]) {
			perror("Get line failed\n");
			ret = EXIT_FAILURE;
			goto close_chip;
		}

		//mode = (chmode[i] == INVALID_MODE)? VOLTAGE_MODE : chmode[i];
		if(chmode[i] != INVALID_MODE)
		{
			//printf("[%d]: chmode[i]=%d, mode=%d\n", i, chmode[i], mode);
			ret = gpiod_line_request_output(line[i], CONSUMER, chmode[i]);
			if (ret < 0) {
				perror("request line as output failed.\n");
				goto release_lines;
			}
			ret = gpiod_line_set_value(line[i], chmode[i]);
			if (ret < 0) {
				perror("set line output failed.\n");
				goto release_lines;
			}
		}
	}
	ret = EXIT_SUCCESS;


	// loop to read for testing
	//while(1)
	{
	for(i=0; i<DIFFGROUP_MAX; i++)
	{
		if(groupmode[i] == VOLTAGE_MODE)
		{
			diffmode = true;
			printf("CH_%d&%d = %.2f V | ", i*DIFFGROUP_MAX, i*DIFFGROUP_MAX+1, readVoltageDiff(i));
		}
		else if(groupmode[i] == CURRENT_MODE)
		{
			diffmode = true;
			printf("CH_%d&%d = %.2f mA | ", i*DIFFGROUP_MAX, i*DIFFGROUP_MAX+1, readCurrentDiff(i));
		}
	}
	if(!diffmode)
	{
		for(i=0; i<CHANNEL_MAX; i++)
		{
			if(chmode[i] == VOLTAGE_MODE)
				printf("CH_%d = %.2f V | ", i, readVoltage(i));
			else if(chmode[i] == CURRENT_MODE)
				printf("CH_%d = %.2f mA | ", i, readCurrent(i));
		}
	}
	printf("\n");
	sleep(2);
	}

release_lines:
	for (i = 0; i < ADC_SET_PIN_MAX; i++)
		gpiod_line_release(line[i]);
close_chip:
	gpiod_chip_close(chip0);
	gpiod_chip_close(chip2);
end:
	closeI2CBus();
	return ret;
}
