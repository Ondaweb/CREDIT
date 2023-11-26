=begin Running the program will show the number of reinforcements earned over the course of
a 160 trials, binned in 16 trial intervals. The result are also stored in a spreadsheet
"output.xls" for later statistical analysis (if needed). These results can be compared to
running the program again except without the "fixer" effect of reinforcement by 
commenting out just line 73.
=end
require 'matrix'
require 'spreadsheet'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end #code to allow putting individual elements in matrix at i,j
brain=	Matrix[ [3,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
				[0,3,0,0,0,0,0,0,0,0,0,0,0,0,1],
				[0,0,3,0,0,0,0,0,1,1,0,0,0,0,0],
				[0,0,0,3,0,0,0,0,1,1,0,0,0,0,0],
				[0,0,0,0,3,0,0,0,0,0,1,1,0,0,0],
				[0,0,0,0,0,3,0,0,0,0,1,1,0,0,0],
				[0,0,0,0,0,0,3,0,0,0,0,0,1,1,0],
				[0,0,0,0,0,0,0,3,0,0,0,0,1,1,0] ]
longmem=Matrix[ [3,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
				[0,3,0,0,0,0,0,0,0,0,0,0,0,0,1],
				[0,0,3,0,0,0,0,0,1,1,0,0,0,0,0],
				[0,0,0,3,0,0,0,0,1,1,0,0,0,0,0],
				[0,0,0,0,3,0,0,0,0,0,1,1,0,0,0],
				[0,0,0,0,0,3,0,0,0,0,1,1,0,0,0],
				[0,0,0,0,0,0,3,0,0,0,0,0,1,1,0],
				[0,0,0,0,0,0,0,3,0,0,0,0,1,1,0] ]
stimulus=Matrix.column_vector([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
behavior=Matrix.column_vector([0,0,0,0,0,0,0,0])
sequence=Matrix.column_vector([0,0,0,0])
success=Matrix.column_vector([0,1,1,0])
$Threshold=89
$Stimmax=14
$Behavmax=7
$Trials=159
$Choices=2#AND NO MORE! OR ELSE STIMULUS GOES OUT OF RANGE
LEARN_RATIO=11 
DECAY_RATE=2
succcesses=0
binat = [15,31,47,63,79,95,111,127,143,159]

spreadsheet_name = 'output.xls'
book = nil
if File.file?(spreadsheet_name)
   book = Spreadsheet.open spreadsheet_name
else
   book = Spreadsheet::Workbook.new
end
sheet = book.worksheet(0) || book.create_worksheet
row_idx = sheet.count

# define methods
def learn(ix, brain, stimulus)
for j in (8..$Stimmax)
	if brain[ix,j]>0 && stimulus[j,0]>0 then brain[ix,j] += LEARN_RATIO end
	if brain[ix,j] > $Threshold then brain[ix,j] = $Threshold end
end # for j
end #learn
def decay(brain,longmem)
		for i in (0..$Behavmax)
		for j in (8..$Stimmax)
    		if brain[i,j] > DECAY_RATE then brain[i,j] -= DECAY_RATE end
    		if brain[i,j] < longmem[i,j] then brain[i,j] = longmem[i,j] end		
		end #for j
		end #for i
end	#decay
def positive_fixer(brain,stimulus,longmem)
	for i in (0..$Behavmax)
    for j in (8..$Stimmax)
    	if brain[i,j] > longmem[i,j] then longmem[i,j] = brain[i,j] end
    end # for j
    end # for i
end #positive fixer
#srand(198)
# begin MAIN PROGRAM
 (0..3).each { |i| success[i, 0] = rand(0..1) }
for trial in (0..$Trials) # $Trials=number of times to run the maze
for cp in (0..$Choices) #Choose left or right turn at first 3 choice points
	happy=0; if cp==0 then stimulus[14,0]=1 else stimulus[14,0]=0 end
	begin
		stimulus[2*cp,0]=rand(10..31); stimulus[2*cp+1,0]=rand(10..32)
		behavior=brain*stimulus
		if behavior[2*cp,0] > $Threshold then learn(2*cp,brain,stimulus);
							stimulus[2*cp+8,0]=1; sequence[cp,0] = 0; happy=1	
		 elsif behavior[2*cp+1,0] > $Threshold then learn(2*cp+1,brain,stimulus);
							stimulus[2*cp+9,0]=1; sequence[cp,0] = 1; happy=1
		 else happy==0 end
	end until happy==1
	decay(brain,longmem)
end #Choices	
cp=3; happy=0 #Choose left or right turn at last choice point
begin
	stimulus[2*cp+1,0]=rand(10..31); stimulus[2*cp,0]=rand(10..32)
	behavior=brain*stimulus
		if behavior[6,0] > $Threshold then learn(6,brain,stimulus);
										sequence[3,0] = 0; happy=1
		elsif behavior[7,0] > $Threshold then learn(7,brain,stimulus);
										sequence[3,0] = 1; happy=1
		else happy==0 end
end until happy==1
decay(brain,longmem)
decay(brain,longmem) # looks good
if sequence==success then positive_fixer(brain, stimulus, longmem); succcesses += 1 end
# reset simulus martix
for j in (0..$Stimmax)
	if stimulus[j,0] > 0 then stimulus[j,0] = 0 end
end # for j
decay(brain,longmem)
decay(brain,longmem)
if trial == binat[0] 
  print "#{succcesses}  ";
  sheet.row(row_idx).push(succcesses)
  succcesses=0; 
  binat[0..0]=[]; 
end
end # of trials
puts
longmem.to_a.each {|r| puts r.inspect}
puts
# endof program

book.write spreadsheet_name