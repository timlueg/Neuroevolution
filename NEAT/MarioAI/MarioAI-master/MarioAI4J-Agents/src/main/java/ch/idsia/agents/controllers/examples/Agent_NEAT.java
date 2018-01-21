package ch.idsia.agents.controllers.examples;

import ch.idsia.agents.AgentOptions;
import ch.idsia.agents.IAgent;
import ch.idsia.agents.controllers.MarioHijackAIBase;
import ch.idsia.benchmark.mario.MarioSimulator;
import ch.idsia.benchmark.mario.engine.input.MarioInput;
import ch.idsia.benchmark.mario.environments.MarioEnvironment;
import ch.idsia.benchmark.mario.options.AIOptions;
import ch.idsia.benchmark.mario.options.FastOpts;
import com.mathworks.engine.EngineException;
import com.mathworks.engine.MatlabEngine;
import com.mathworks.matlab.types.Struct;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.api.ops.Op;
import org.nd4j.linalg.api.ops.impl.accum.MatchCondition;
import org.nd4j.linalg.api.ops.impl.indexaccum.IAMax;
import org.nd4j.linalg.api.ops.impl.transforms.Tanh;
import org.nd4j.linalg.cpu.nativecpu.NDArray;
import org.nd4j.linalg.factory.Nd4j;
import org.nd4j.linalg.indexing.NDArrayIndex;
import org.nd4j.linalg.indexing.conditions.Conditions;

/**
 * Usage:
 * Add  matlabroot/bin/<arch> as environment variable
 * Run "matlab.engine.shareEngine" in matlab console to share session
 * Run Agent_NEAT
 * <p>
 * Further Details see mathworks.com/help/matlab/matlab_external/setup-environment.html
 **/

public class Agent_NEAT extends MarioHijackAIBase implements IAgent {

	static MatlabEngine eng;
	Struct params;
	double[] tiles = new double[AIOptions.getReceptiveFieldWidth() * AIOptions.getReceptiveFieldHeight()];
	INDArray weightMatrix;
	INDArray activation;

	@Override
	public void reset(AgentOptions options) {
		super.reset(options);
	}

	@Override
	public MarioInput actionSelectionAI() {


		//todo only train every x frames.
		//control.jump();
		//control.runRight();


			/*Double enteties = new Double(e.entities.size());
			for (int i = 0; i < e.entities.size(); i++) {
				if(e.entities.get(i).type.equals(EntityType.DANGER))
			}*/

		int index = 0;
		for (int i = 0; i < t.tileField.length; i++) {
			for (int j = 0; j < t.tileField[i].length; j++) {
				tiles[index++] = (double) t.tileField[i][j].getCode();
			}
		}

		INDArray inputTiles = Nd4j.create(tiles);
		activation = Nd4j.concat(1, inputTiles, activation.get(NDArrayIndex.interval(inputTiles.length(), activation.length())));
		INDArray netOut = Nd4j.getExecutioner().execAndReturn(new Tanh((activation.mmul(weightMatrix))));
		//activation = netOut;

		netOut = netOut.get(NDArrayIndex.interval(inputTiles.length(), inputTiles.length() + ((Double) params.get("num_output")).intValue()));

		Double maxValue = Double.NEGATIVE_INFINITY;
		int keyId = 0;
		for (int i = 0; i < netOut.length(); i++) {
			if(netOut.getDouble(i) > maxValue) {
				maxValue = netOut.getDouble(i);
				keyId = i;
			}
		}

		if (keyId == 1) {
			control.jump();
		} else if (keyId == 2) {
			control.runLeft();
		} else if (keyId == 3) {
			control.jump();
		}


		return action;
	}


	public static void main(String[] args) throws Exception {

		String options = FastOpts.VIS_ON_2X + FastOpts.LEVEL_04_BLOCKS;
		MarioSimulator simulator = new MarioSimulator(options);
		IAgent agent = new Agent_NEAT();

		agent.receiveReward(MarioEnvironment.getInstance().getIntermediateReward());

		eng = MatlabEngine.connectMatlab(MatlabEngine.findMatlab()[0]);
		eng.eval("neat_network()");

		/*
		eng.putVariable("isTraining", true);
		for (int i = 0; i < 10; i++) {
			eng.putVariable("newSimulationStarted", true);
			simulator.run(agent);
			eng.putVariable("fitnessReward", MarioEnvironment.getInstance().getIntermediateReward());
			System.out.println("finished 1 simulation");
		}*/

		closeMatlabEngineOnManualExit();


		((Agent_NEAT)agent).params = eng.getVariable("params");
		Object[] nodes = (Object[]) ((Agent_NEAT)agent).params.get("nodes");
		Object[] connections = (Object[]) ((Agent_NEAT)agent).params.get("connections");

		int currentNetworkId = 1;
		INDArray nodesCurrent = Nd4j.create((double[][]) nodes[currentNetworkId]);
		INDArray connectionsCurrent = Nd4j.create((double[][]) connections[currentNetworkId]);

		int maxNodeId = nodesCurrent.getColumn(0).maxNumber().intValue();

		//remove disabled connections
		INDArray enabledSelector = connectionsCurrent.getColumn(3).eq(1d);
		int[] enabledIndex = new int[Nd4j.getExecutioner().exec(new MatchCondition(enabledSelector, Conditions.equals(1)), Integer.MAX_VALUE).getInt(0)];
		int indexCounter = 0;
		for (int i = 0; i < enabledSelector.length(); i++) {
			if (enabledSelector.getInt(i) == 1) {
				enabledIndex[indexCounter++] = i;
			}
		}
		connectionsCurrent = connectionsCurrent.getRows(enabledIndex).getColumns(0, 1, 2);

		((Agent_NEAT) agent).activation = Nd4j.zeros(1, maxNodeId);
		((Agent_NEAT) agent).weightMatrix = (NDArray) Nd4j.zeros(maxNodeId, maxNodeId);
		for (int i = 0; i < connectionsCurrent.getColumn(0).size(0); i++) {
			((Agent_NEAT) agent).weightMatrix.put(connectionsCurrent.getColumn(0).getInt(i) - 1, connectionsCurrent.getColumn(1).getInt(i) - 1, connectionsCurrent.getColumn(2).getDouble(i));
		}

		simulator.run(agent);

		int fitness = MarioEnvironment.getInstance().getIntermediateReward();
		System.out.println(fitness);
		System.exit(0);

	}

	private static void closeMatlabEngineOnManualExit() {
		Runtime.getRuntime().addShutdownHook(new Thread() {
			public void run() {
				try {
					eng.close();
				} catch (EngineException e1) {
					e1.printStackTrace();
				}
			}
		});
	}
}
